import Foundation
import Swifter

class Server {
    
    private var server:Socket? = nil;
    
     init() {
        do {
            server = try Socket.tcpSocketForListen(1625, true);
        }
        catch {
        
        }
    }
    
    private func startListenting() -> Void {
        
    }
}
