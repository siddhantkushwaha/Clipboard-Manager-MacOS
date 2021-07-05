import Foundation
import SwiftyJSON
import Socket

class Server {
    
    let port:Int
    init(port: Int) {
        self.port = port
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
            
            let messageUnserialized = JSON(parseJSON: messageReceived)
            
            // consume this message
            print(messageUnserialized)
            
            let response = [
                "status": 0
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
