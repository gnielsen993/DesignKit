import Foundation

public struct ThemeBackupService {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public static var fileExtension: String { "dktheme" }

    public func exportConfiguration(
        _ configuration: ThemeBackupConfiguration,
        to url: URL
    ) throws {
        let parentDirectory = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parentDirectory.path) {
            try fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        }

        let data = try ThemeBackupCodec.encodeJSON(configuration)
        try data.write(to: url, options: .atomic)
    }

    public func importConfiguration(from url: URL) throws -> ThemeBackupConfiguration {
        let data = try Data(contentsOf: url)
        return try ThemeBackupCodec.decodeJSON(data)
    }
}
