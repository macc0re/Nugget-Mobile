
//
//  Restore.swift
//  Nugget
//
//  Created by lemin on 9/11/24.
//

import Foundation

enum RestoreError: LocalizedError {
    case emptyFileList
    case invalidUDID
    case invalidPath(String)
    case fileOperationFailed(path: String, reason: String)
    case backupRestoreFailed(exitCode: Int32)

    var errorDescription: String? {
        switch self {
        case .emptyFileList:
            return "No files were provided for restoration."

        case .invalidUDID:
            return "The device UDID is invalid or empty."

        case .invalidPath(let path):
            return "Invalid restoration path: \(path)"

        case .fileOperationFailed(let path, let reason):
            return "Failed to process \(path): \(reason)"

        case .backupRestoreFailed(let exitCode):
            return "idevicebackup2 failed with exit code \(exitCode)."
        }
    }
}

struct FileToRestore {
    let contents: Data
    let path: String
    var owner: Int32 = 501
    var group: Int32 = 501
    var usesInodes: Bool = true
}

class RestoreManager {
    static let shared = RestoreManager()

    private func validateFiles(_ files: [FileToRestore]) throws {
        guard !files.isEmpty else {
            throw RestoreError.emptyFileList
        }

        for file in files {
            guard !file.path.isEmpty,
                  !file.path.contains("\0") else {
                throw RestoreError.invalidPath(file.path)
            }

            if !file.path.starts(with: "/") {
                let components = file.path.components(separatedBy: "/")

                guard components.count >= 2,
                      components.allSatisfy({
                          !$0.isEmpty && $0 != "." && $0 != ".."
                      }) else {
                    throw RestoreError.invalidPath(file.path)
                }
            }
        }
    }

    private func addExploitedConcreteFile(
        list: inout [BackupFile],
        path: String,
        contents: Data,
        owner: Int32 = 501,
        group: Int32 = 501,
        last_domain: inout String
    ) {
        let url = URL(filePath: path)
        var basePath: String = "/var/backup"

        if #available(iOS 17, *) {
            basePath = url.path(percentEncoded: false)
                .hasPrefix("/var/mobile/")
                ? "/var/mobile/backup"
                : "/var/backup"
        }

        if last_domain != url.deletingLastPathComponent().path(percentEncoded: false) {
            last_domain = url.deletingLastPathComponent().path(percentEncoded: false)

            list.append(
                Directory(
                    path: "",
                    domain: "SysContainerDomain-../../../../../../../..\(basePath)\(last_domain)",
                    owner: owner,
                    group: group
                )
            )
        }

        list.append(
            ConcreteFile(
                path: "",
                domain: "SysContainerDomain-../../../../../../../..\(basePath)\(url.path(percentEncoded: false))",
                contents: contents,
                owner: owner,
                group: group
            )
        )
    }

    private func addRegularConcreteFile(
        list: inout [BackupFile],
        path: String,
        contents: Data,
        owner: Int32 = 501,
        group: Int32 = 501,
        last_path: inout String,
        last_domain: inout String
    ) {
        let path_items = path.components(separatedBy: "/")
        let domain = path_items[0]

        var startIdx = 0

        if last_domain == domain {
            startIdx = 1
            let last_path_items = last_path.components(separatedBy: "/")

            for (i, last_path_item) in last_path_items.enumerated() {
                if i + 1 < path_items.count &&
                    last_path_item == path_items[i + 1] {
                    startIdx += 1
                } else {
                    break
                }
            }
        }

        if startIdx == 0 {
            list.append(Directory(path: "", domain: domain))
            startIdx = 1
        }

        last_domain = domain

        var full_path = ""

        for i in 1...(path_items.count - 1) {
            if full_path != "" {
                full_path += "/"
            }

            full_path += path_items[i]

            if i >= startIdx {
                if i < path_items.count - 1 {
                    last_path = full_path
                    list.append(Directory(path: full_path, domain: domain))
                } else {
                    list.append(
                        ConcreteFile(
                            path: full_path,
                            domain: domain,
                            contents: contents,
                            owner: owner,
                            group: group
                        )
                    )
                }
            }
        }
    }

    // MARK: - TrollStore Restore

    func tsRestoreFiles(_ files: [FileToRestore]) throws {
        try validateFiles(files)

        for file in files {
            var filePath = file.path

            if file.path.starts(with: "HomeDomain/") {
                filePath = file.path.replacingOccurrences(
                    of: "HomeDomain/",
                    with: "/var/mobile/"
                )
            }

            let url = URL(fileURLWithPath: filePath)

            do {
                if file.contents.isEmpty {
                    if FileManager.default.fileExists(atPath: filePath) {
                        try FileManager.default.removeItem(at: url)
                    }
                } else {
                    try file.contents.write(to: url, options: .atomic)
                }

                print("Processed: \(filePath)")
            } catch {
                throw RestoreError.fileOperationFailed(
                    path: filePath,
                    reason: error.localizedDescription
                )
            }
        }
    }

    // MARK: - SparseRestore

    func restoreFiles(
        _ files: [FileToRestore],
        udid: String
    ) throws {
        try validateFiles(files)

        guard !udid.isEmpty else {
            throw RestoreError.invalidUDID
        }

        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let folder = documentsDirectory.appendingPathComponent(
            udid,
            conformingTo: .data
        )

        do {
            if FileManager.default.fileExists(atPath: folder.path) {
                try FileManager.default.removeItem(at: folder)
            }

            try FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: false
            )

            let sortedFiles = files.sorted { file1, file2 in
                if file1.path.starts(with: "/") &&
                    !file2.path.starts(with: "/") {
                    return false
                } else if !file1.path.starts(with: "/") &&
                            file2.path.starts(with: "/") {
                    return true
                }

                return file1.path < file2.path
            }

            var backupFiles: [BackupFile] = []
            var last_path = ""
            var last_domain = ""
            var exploit_only = true

            print("Files: [")

            for file in sortedFiles {
                print(file.path + ",")

                if file.path.starts(with: "/") {
                    addExploitedConcreteFile(
                        list: &backupFiles,
                        path: file.path,
                        contents: file.contents,
                        owner: file.owner,
                        group: file.group,
                        last_domain: &last_domain
                    )
                } else {
                    exploit_only = false

                    addRegularConcreteFile(
                        list: &backupFiles,
                        path: file.path,
                        contents: file.contents,
                        owner: file.owner,
                        group: file.group,
                        last_path: &last_path,
                        last_domain: &last_domain
                    )
                }
            }

            if exploit_only {
                backupFiles.append(
                    ConcreteFile(
                        path: "",
                        domain: "SysContainerDomain-../../../../../../../../crash_on_purpose",
                        contents: Data(),
                        owner: 501,
                        group: 501
                    )
                )
            }

            print("]")

            let mbdb = Backup(files: backupFiles)
            try mbdb.writeTo(directory: folder)

            let restoreArgs = [
                "idevicebackup2",
                "-n",
                "restore",
                "--no-reboot",
                "--system",
                documentsDirectory.path(percentEncoded: false)
            ]

            print("Executing args: \(restoreArgs)")

            var argv = restoreArgs.map { strdup($0) }

            defer {
                for argument in argv {
                    free(argument)
                }
            }

            let result = idevicebackup2_main(
                Int32(restoreArgs.count),
                &argv
            )

            print("idevicebackup2 exited with code \(result)")

            guard result == 0 else {
                throw RestoreError.backupRestoreFailed(
                    exitCode: result
                )
            }

        } catch let error as RestoreError {
            print(error.localizedDescription)
            throw error
        } catch {
            print(error.localizedDescription)

            throw RestoreError.fileOperationFailed(
                path: folder.path,
                reason: error.localizedDescription
            )
        }
    }
}
