import Foundation
import Socket
import SwiftyJSON

class Client {
    
    let port: Int
    init(port:Int) {
        self.port = port
    }
    
    private func sendMessage(message:String) -> String? {
        var messageReceived:String? = nil
        do {
            let serverSocket = try Socket.create()
            try serverSocket.connect(to: "localhost", port: Int32(self.port), timeout: 5000)
            
            try serverSocket.setReadTimeout(value:5000)
            try serverSocket.setWriteTimeout(value:5000)
            
            let _ = try serverSocket.write(from: message)
            
            messageReceived = try serverSocket.readString()
        }
        catch let error {
            print(error.localizedDescription)
        }
        return messageReceived
    }
    
    public func sendMessage(message:JSON) -> JSON? {
        let messageSerialized = message.rawString()!
        let messageReceived = sendMessage(message: messageSerialized)!
        
        let messageUnserialized = JSON(parseJSON: messageReceived)
        return messageUnserialized
    }
}
