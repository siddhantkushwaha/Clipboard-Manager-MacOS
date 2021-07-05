import Cocoa

public func monitorClipboard() {
    
    let pasteboard: NSPasteboard = NSPasteboard.general
    var count: Int = pasteboard.changeCount

    repeat{

        usleep(2 * 1000 * 1000)

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

                    for fileURL in fileURls {
                        print(fileURL)
                    }

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

                    print(stringData)

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

    } while true
}

monitorClipboard()

// let server = Server(port: 1625)
// server.startListening()

// let client = Client(port: 1626)
// let response = client.sendMessage(message: ["key":"val", "key2":1])
// print(response)
