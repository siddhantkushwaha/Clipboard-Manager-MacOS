import Foundation
import Socket
import SwiftyJSON

class Server {
    
    let port:Int
    let clipboardApp:ClipboardApp
    
    init(port: Int, clipboardApp:ClipboardApp) {
        self.port = port
        self.clipboardApp = clipboardApp
    }
       
    public func startListening() {
        do {
            var newClientSocket = try Socket.create()
            try newClientSocket.listen(on: self.port, maxBacklogSize: 10, allowPortReuse: false)

            while (true) {
                print("Listening for new client.")
                try newClientSocket.acceptConnection()

                let clientSocket = newClientSocket
                DispatchQueue.global(qos: .background).async {
                    self.handleClient(clientSocket:clientSocket)
                }

                newClientSocket = try Socket.create()
                try newClientSocket.listen(on: self.port, maxBacklogSize: 10, allowPortReuse: false)
            }
        }
        catch let error {
            print(error.localizedDescription)
            exit(1)
        }
    }
    
    private func handleClient(clientSocket: Socket) {
        do {
            try clientSocket.setReadTimeout(value:5000)
            try clientSocket.setWriteTimeout(value:5000)
            
            let messageReceived = try clientSocket.readString()!
            print("Message received", messageReceived)
            
            var status = 1
            if let messageUnserialized:Dictionary<String, Any> = JSON(parseJSON: messageReceived).dictionary {
                let messageType = messageUnserialized["messageType"] as? String ?? ""
                switch messageType {
                case "updateClipboard":
                    
                    if let updateMessage = messageUnserialized["updateMessage"] as? Dictionary<String, Any> {
                        clipboardApp.updateClipboard(update: updateMessage)
                        status = 0
                    }
                    
                    break
                default:
                    
                    // type not supported
                    
                    break
                }
            }
            
            let response = [
                "status": status
            ]
            let responseSerialized = JSON(response).rawString()!
            
            try clientSocket.write(from: responseSerialized)
            clientSocket.close()
        }
        catch let error {
            print(error.localizedDescription)
            exit(1)
        }
    }
}
