import Foundation
import ZIPFoundation

struct ScanResult: Identifiable {
    let id = UUID()
    let fileName: String
    let matches: [String]
    let entryCount: Int

    var detected: Bool { !matches.isEmpty }
}

enum UnityScannerError: LocalizedError {
    case unsupportedFile
    case cannotOpenArchive

    var errorDescription: String? {
        switch self {
        case .unsupportedFile:
            return "Choose an .ipa or .zip archive."
        case .cannotOpenArchive:
            return "Could not open this archive. It may be invalid or encrypted."
        }
    }
}

enum UnityScanner {
    private static let markers: [(needle: String, label: String)] = [
        ("unityframework.framework", "UnityFramework.framework"),
        ("unity-iphone", "Unity-iPhone"),
        ("data/managed", "Data/Managed"),
        ("globalgamemanagers", "globalgamemanagers"),
        ("libil2cpp", "libil2cpp"),
        ("resources/unity_builtin_extra", "Unity built-in resources")
    ]

    static func scan(url: URL) async throws -> ScanResult {
        let ext = url.pathExtension.lowercased()
        guard ext == "ipa" || ext == "zip" else {
            throw UnityScannerError.unsupportedFile
        }

        return try await Task.detached(priority: .userInitiated) {
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess { url.stopAccessingSecurityScopedResource() }
            }

            guard let archive = Archive(url: url, accessMode: .read) else {
                throw UnityScannerError.cannotOpenArchive
            }

            var entries: [String] = []
            var entryCount = 0
            for entry in archive {
                entryCount += 1
                entries.append(entry.path.lowercased())
            }

            let joinedPaths = entries.joined(separator: "\n")
            let matches = markers.compactMap { marker in
                joinedPaths.contains(marker.needle) ? marker.label : nil
            }

            return ScanResult(
                fileName: url.lastPathComponent,
                matches: matches,
                entryCount: entryCount
            )
        }.value
    }
}
