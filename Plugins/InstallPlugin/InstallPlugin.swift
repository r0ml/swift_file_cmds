// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026


import PackagePlugin
import Foundation

@main
struct InstallPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Configuration
        let toolName = "mytool"          // change to your executable target name
        let linkName = "mytool-alias"    // symlink name
        let installDir = "/usr/local/bin"

        // Build the tool in release configuration
        let build = try context.packageManager.build(.root, configuration: .release)
        // Find the built binary
        let builtProductsDir = build.builtArtifactsDirectory
        let toolPath = builtProductsDir.appending(subpath: toolName)

        // Ensure target exists
        guard FileManager.default.fileExists(atPath: toolPath.string) else {
            throw PluginError.missingBinary(toolPath.string)
        }

        // Run shell commands to install and link (will likely require sudo from Terminal)
        try runShell("/usr/bin/install", ["-d", "-m", "0755", installDir])
        try runShell("/usr/bin/install", ["-m", "0755", toolPath.string, "\(installDir)/\(toolName)"])
        try runShell("/bin/ln", ["-sfn", toolName, "\(installDir)/\(linkName)"])

        context.console.print("Installed \(toolName) -> \(installDir) and linked \(linkName) -> \(toolName)")
    }
}

enum PluginError: Error, CustomStringConvertible {
    case missingBinary(String)
    var description: String {
        switch self {
        case .missingBinary(let path): return "Built binary not found at: \(path)"
        }
    }
}

@discardableResult
func runShell(_ tool: String, _ arguments: [String]) throws -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: tool)
    process.arguments = arguments
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { throw ShellError.nonZeroExit(process.terminationStatus) }
    return process.terminationStatus
}

enum ShellError: Error {
    case nonZeroExit(Int32)
}