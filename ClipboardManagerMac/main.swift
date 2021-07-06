import Foundation
import Cocoa

private func main() {
    var clipboardManagerport = -1
    var clipboardServerPort = -1
    if (CommandLine.arguments.count >= 3) {
        clipboardManagerport = Int(CommandLine.arguments[1]) ?? -1
        clipboardServerPort = Int(CommandLine.arguments[2]) ?? -1
    }

    if (clipboardManagerport == -1 || clipboardServerPort == -1) {
        print("Invalid args.")
        exit(1)
    }
    
    print("Start clipboard maanger on port", clipboardManagerport)
    print("Clipboard server port", clipboardServerPort)
    
    let clipboardApp = ClipboardApp(clipboardServerPort: clipboardServerPort)
        
    // start clipboard monitoring in the background
    DispatchQueue.global(qos: .background).async {
        clipboardApp.startListening()
    }
    
    print("Starting clipboard manager server.")
    let server = Server(port: clipboardManagerport)
    server.startListening()
}

main()
