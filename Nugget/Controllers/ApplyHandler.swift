
//
//  ApplyHandler.swift
//  Nugget
//
//  Created by lemin on 9/11/24.
//

import Foundation

enum TweakPage: String, CaseIterable {
    case MobileGestalt = "Mobilegestalt"
    case FeatureFlags = "Feature Flags"
    case Eligibility = "Eligibility"
    case StatusBar = "Status Bar"
    case SpringBoard = "SpringBoard"
    case Internal = "Internal Options"
    case SkipSetup = "Skip Setup"
}

class ApplyHandler: ObservableObject {
    static let shared = ApplyHandler()

    let gestaltManager = MobileGestaltManager.shared
    let ffManager = FeatureFlagManager.shared
    let eligibilityManager = EligibilityManager.shared
    let statusManager = StatusManagerSwift.shared

    @Published var enabledTweaks: Set<TweakPage> = []

    @Published var removingTweaks: Set<TweakPage> = [
        .MobileGestalt, .FeatureFlags, .SpringBoard, .Internal
    ]

    @Published var trollstore: Bool = false

    init() {
        do {
            try FileManager.default.contentsOfDirectory(
                at: URL(fileURLWithPath: "/var/mobile/Library/Caches"),
                includingPropertiesForKeys: nil
            )
            trollstore = true
        } catch {
            trollstore = false
        }
    }

    // MARK: - Modifying Enabled Tweaks

    func setTweakEnabled(_ tweak: TweakPage, isEnabled: Bool) {
        if isEnabled {
            enabledTweaks.insert(tweak)
        } else {
            enabledTweaks.remove(tweak)
        }
    }

    func isTweakEnabled(_ tweak: TweakPage) -> Bool {
        return enabledTweaks.contains(tweak)
    }

    func allEnabledTweaks() -> Set<TweakPage> {
        return enabledTweaks
    }

    // MARK: - Getting Data For Each Tweak

    func getTweakPageData(
        _ tweakPage: TweakPage,
        resetting: Bool,
        files: inout [FileToRestore]
    ) throws {
        switch tweakPage {

        case .MobileGestalt:
            if let mobileGestaltData: Data = resetting
                ? gestaltManager.reset()
                : try gestaltManager.apply() {

                files.append(
                    FileToRestore(
                        contents: mobileGestaltData,
                        path: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
                    )
                )
            }

            if let resChangerData: Data = resetting
                ? Data()
                : gestaltManager.applyRdarFix() {

                files.append(
                    FileToRestore(
                        contents: resChangerData,
                        path: FileLocation.resolution.rawValue
                    )
                )
            }

        case .FeatureFlags:
            let ffData: Data = resetting
                ? try ffManager.reset()
                : try ffManager.apply()

            files.append(
                FileToRestore(
                    contents: ffData,
                    path: "/var/preferences/FeatureFlags/Global.plist"
                )
            )

        case .Eligibility:
            let changes: [String: Data] = resetting
                ? try eligibilityManager.revert()
                : try eligibilityManager.apply()

            for (file, newData) in changes {
                files.append(
                    FileToRestore(
                        contents: newData,
                        path: file
                    )
                )
            }

        case .StatusBar:
            let statusBarData: Data = resetting
                ? try statusManager.reset()
                : try statusManager.apply()

            files.append(
                FileToRestore(
                    contents: statusBarData,
                    path: "HomeDomain/Library/SpringBoard/statusBarOverrides",
                    usesInodes: false
                )
            )

        case .SpringBoard, .Internal:
            let basicPlistTweaksData =
                BasicPlistTweaksManager.applyPage(
                    tweakPage,
                    resetting: resetting
                )

            for (filePath, data) in basicPlistTweaksData {
                files.append(
                    FileToRestore(
                        contents: data,
                        path: filePath.rawValue
                    )
                )
            }

        case .SkipSetup:
            var cloudConfigData = Data()
            var purpleBuddyData = Data()

            if !resetting {
                let cloudConfigPlist: [String: Any] = [
                    "SkipSetup": [
                        "WiFi", "Location", "Restore", "SIMSetup",
                        "Android", "AppleID", "IntendedUser", "TOS",
                        "Siri", "ScreenTime", "Diagnostics",
                        "SoftwareUpdate", "Passcode", "Biometric",
                        "Payment", "Zoom", "DisplayTone",
                        "MessagingActivationUsingPhoneNumber",
                        "HomeButtonSensitivity", "CloudStorage",
                        "ScreenSaver", "TapToSetup", "Keyboard",
                        "PreferredLanguage", "SpokenLanguage",
                        "WatchMigration", "OnBoarding",
                        "TVProviderSignIn", "TVHomeScreenSync",
                        "Privacy", "TVRoom",
                        "iMessageAndFaceTime", "AppStore", "Safety",
                        "Multitasking", "ActionButton",
                        "TermsOfAddress", "AccessibilityAppearance",
                        "Welcome", "Appearance", "RestoreCompleted",
                        "UpdateCompleted"
                    ],
                    "AllowPairing": true,
                    "ConfigurationWasApplied": true,
                    "CloudConfigurationUIComplete": true,
                    "ConfigurationSource": 0,
                    "PostSetupProfileWasInstalled": true,
                    "IsSupervised": false
                ]

                cloudConfigData =
                    try PropertyListSerialization.data(
                        fromPropertyList: cloudConfigPlist,
                        format: .xml,
                        options: 0
                    )

                let purpleBuddyPlist: [String: Any] = [
                    "SetupDone": true,
                    "SetupFinishedAllSteps": true,
                    "UserChoseLanguage": true
                ]

                purpleBuddyData =
                    try PropertyListSerialization.data(
                        fromPropertyList: purpleBuddyPlist,
                        format: .xml,
                        options: 0
                    )
            }

            if resetting || !self.isExploitOnly() {
                files.append(
                    FileToRestore(
                        contents: cloudConfigData,
                        path: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
                    )
                )

                if !self.isExploitOnly() {
                    files.append(
                        FileToRestore(
                            contents: purpleBuddyData,
                            path: "ManagedPreferencesDomain/mobile/com.apple.purplebuddy.plist"
                        )
                    )
                }
            }
        }
    }

    // MARK: - Path Conversion

    func convertToDomain(path: String) -> String? {
        if !path.starts(with: "/") {
            return path
        }

        var sysSharedContainer = "SysSharedContainerDomain-"
        var sysContainer = "SysContainerDomain-"

        if !isFullyPatched() {
            sysSharedContainer += "."
            sysContainer += "."
        }

        let mappings: [String: String] = [
            "/var/Managed Preferences": "ManagedPreferencesDomain",
            "/var/root": "RootDomain",
            "/var/preferences": "SystemPreferencesDomain",
            "/var/MobileDevice": "MobileDeviceDomain",
            "/var/mobile": "HomeDomain",
            "/var/db": "DatabaseDomain",
            "/var/containers/Shared/SystemGroup/": sysSharedContainer,
            "/var/containers/Data/SystemGroup/": sysContainer
        ]

        for (rootPath, domain) in mappings {
            if path.starts(with: rootPath) {
                return path.replacingOccurrences(
                    of: rootPath,
                    with: domain
                )
            }
        }

        return nil
    }

    // MARK: - Version Checks

    func isFullyPatched() -> Bool {
        if #available(iOS 18.2, *) {
            var osVersionString = [CChar](
                repeating: 0,
                count: 16
            )

            var osVersionStringLen = size_t(
                osVersionString.count - 1
            )

            let result = sysctlbyname(
                "kern.osversion",
                &osVersionString,
                &osVersionStringLen,
                nil,
                0
            )

            if result == 0 {
                if let build = String(validatingUTF8: osVersionString) {
                    if build == "22C5109p" ||
                        build == "22C5125e" {
                        return false
                    }
                } else {
                    print("Failed to convert build number to String")
                }
            } else {
                print(
                    "sysctlbyname failed with error: \(String(cString: strerror(errno)))"
                )
            }

            return true
        }

        return false
    }

    func isExploitPatched() -> Bool {
        if #available(iOS 18.2, *) {
            return true
        }

        if #available(iOS 18.1, *) {
            var osVersionString = [CChar](
                repeating: 0,
                count: 16
            )

            var osVersionStringLen = size_t(
                osVersionString.count - 1
            )

            let result = sysctlbyname(
                "kern.osversion",
                &osVersionString,
                &osVersionStringLen,
                nil,
                0
            )

            if result == 0 {
                if let build = String(validatingUTF8: osVersionString) {
                    if build == "22B5007p" ||
                        build == "22B5023e" ||
                        build == "22B5034e" ||
                        build == "22B5045g" {
                        return false
                    }
                } else {
                    print("Failed to convert build number to String")
                }
            } else {
                print(
                    "sysctlbyname failed with error: \(String(cString: strerror(errno)))"
                )
            }

            return true
        }

        return false
    }

    func isExploitOnly() -> Bool {
        if self.isExploitPatched() {
            return false
        }

        if self.enabledTweaks.contains(.StatusBar) {
            return false
        }

        return true
    }

    // MARK: - Restore Dispatch

    private func restore(
        _ files: [FileToRestore],
        udid: String,
        trollstore: Bool
    ) throws {
        guard !files.isEmpty else {
            throw RestoreError.emptyFileList
        }

        if trollstore {
            try RestoreManager.shared.tsRestoreFiles(files)
            return
        }

        if self.isExploitPatched() {
            var convertedFiles: [FileToRestore] = []

            for file in files {
                guard let newPath = self.convertToDomain(path: file.path) else {
                    throw RestoreError.invalidPath(file.path)
                }

                convertedFiles.append(
                    FileToRestore(
                        contents: file.contents,
                        path: newPath,
                        owner: file.owner,
                        group: file.group,
                        usesInodes: file.usesInodes
                    )
                )

                print("Converted path: \(newPath)")
            }

            try RestoreManager.shared.restoreFiles(
                convertedFiles,
                udid: udid
            )

            return
        }

        try RestoreManager.shared.restoreFiles(
            files,
            udid: udid
        )
    }

    // MARK: - Applying Tweaks

    func apply(
        udid: String,
        skipSetup: Bool,
        trollstore: Bool
    ) -> Bool {
        var filesToRestore: [FileToRestore] = []

        do {
            print("Tweak pages being applied: \(self.enabledTweaks)")

            for tweak in self.enabledTweaks {
                try getTweakPageData(
                    tweak,
                    resetting: false,
                    files: &filesToRestore
                )
            }

            if skipSetup {
                try getTweakPageData(
                    .SkipSetup,
                    resetting: false,
                    files: &filesToRestore
                )
            }

            guard !filesToRestore.isEmpty else {
                print("No files to restore!")
                return false
            }

            try restore(
                filesToRestore,
                udid: udid,
                trollstore: trollstore
            )

            print("All requested files were processed successfully.")
            return true

        } catch {
            print("Apply failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Resetting Tweaks

    func reset(
        udid: String,
        trollstore: Bool
    ) -> Bool {
        var filesToRestore: [FileToRestore] = []

        do {
            print("Tweak pages being reset: \(self.removingTweaks)")

            for tweak in self.removingTweaks {
                try self.getTweakPageData(
                    tweak,
                    resetting: true,
                    files: &filesToRestore
                )
            }

            guard !filesToRestore.isEmpty else {
                print("No files to restore!")
                return false
            }

            try restore(
                filesToRestore,
                udid: udid,
                trollstore: trollstore
            )

            print("All requested files were processed successfully.")
            return true

        } catch {
            print("Reset failed: \(error.localizedDescription)")
            return false
        }
    }
}
