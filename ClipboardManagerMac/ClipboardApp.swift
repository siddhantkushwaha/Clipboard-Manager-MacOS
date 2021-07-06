import Foundation
import Cocoa
import SwiftyJSON

class ClipboardApp {
    
    private let clipboardLock = NSLock()
    
    let pasteboard: NSPasteboard = NSPasteboard.general
    
    var clipboardServerPort = -1
    var waitTimeMicroSeconds:UInt32 = 2 * 1000 * 1000
    
    var lastSuccessfullUpdate: Dictionary<String, Any>? = nil
    
    init(clipboardServerPort: Int) {
        self.clipboardServerPort = clipboardServerPort
    }
    
    private func sendUpdate(update: Dictionary<String, Any>) {
        if let lastUpdate = lastSuccessfullUpdate {
            if (NSDictionary(dictionary: lastUpdate).isEqual(to: update)) {
                print("Matches with last update, discarded.")
                return
            }
        }
        
        let updateString = JSON(update).rawString()
        if let updateString = updateString {
            print("Clipboard changed on local setup, update received.", updateString)
            
            // TODO - send update string to clipboard server
            lastSuccessfullUpdate = update
        }
        else {
            print("Failed to serialize update message.")
        }
    }
    
    public func updateClipboard(update: Dictionary<String, Any>) {
        clipboardLock.lock()
        
        // TDOD - modify clipboard based on update, AND
        lastSuccessfullUpdate = update
        
        clipboardLock.unlock()
    }
    
    public func startListening() {
        var count: Int = pasteboard.changeCount
        repeat {
            usleep(self.waitTimeMicroSeconds)
            
            // take lock before reading pasteboard since it could be modified by updateClipboard
            clipboardLock.lock()
            
            if(count < pasteboard.changeCount) {
                count = pasteboard.changeCount

                var found = false
                for type in pasteboard.types ?? [] {
                    switch type {

                    // files will be handled later on in project Unity
                    case .fileURL:
                        print("Files were copied.")
                        let fileURls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) ?? []
                        if (fileURls.isEmpty) {
                            continue
                        }

                        var files: [String] = []
                        for fileURL in fileURls {
                            let path = NSURL(fileURLWithPath: String(describing: fileURL)).path
                            if let path = path {
                                files.append(path)
                            }
                        }
                        
                        let clipboardUpdate = [
                            "type":2,
                            "files":files
                        ] as [String : Any]
                        sendUpdate(update: clipboardUpdate)

                        // in current pasteboard if file urls are present,
                        // same filenames are also present as string which have to be discarded
                        found = true

                        break

                    // string should have the lowest priority
                    case .string:
                        print("New text added to clipboard.")
                        let stringData = pasteboard.string(forType: type) ?? ""
                        if (stringData.isEmpty) {
                            continue
                        }

                        let clipboardUpdate = [
                            "type":1,
                            "text":stringData
                        ] as [String : Any]
                        sendUpdate(update: clipboardUpdate)

                        // string has lowest priority
                        found = true

                        break
                    default:

                        print("Data format not supported as of now.")

                        break
                    }

                    if (found) {
                        break
                    }
                }
            }
            
            clipboardLock.unlock()

        } while true
    }
}
