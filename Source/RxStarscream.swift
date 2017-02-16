//
//  Created by Guy Kahlon.
//

import Foundation
import RxSwift
import Starscream

import Foundation
import RxSwift
import Starscream

public enum WebSocketEvent {
  case connected
  case disconnected(NSError?)
  case message(String)
  case data(Foundation.Data)
  case pong
}

open class RxWebSocket: WebSocket {
  
  fileprivate let subject = PublishSubject<WebSocketEvent>()
  
  open fileprivate(set) lazy var rx_response: Observable<WebSocketEvent> = {
    return self.subject
  }()
  
  open fileprivate(set) lazy var rx_text: Observable<String> = {
    return self.subject.filter { response in
      switch response {
      case .message(_):
        return true
      default:
        return false
      }
      }.map { response in
        switch response {
        case .message(let message):
          return message
        default:
          return String()
        }
    }
  }()
  
  open override func connect() {
    super.connect()
    delegate = self
    pongDelegate = self
  }
}

extension RxWebSocket: WebSocketPongDelegate {
    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        subject.on(.next(WebSocketEvent.pong))
    }

  public func websocketDidReceivePong(_ socket: WebSocket) {
    subject.on(.next(WebSocketEvent.pong))
  }
}

extension RxWebSocket: WebSocketDelegate {
  
  public func websocketDidConnect(socket: WebSocket) {
    subject.on(.next(WebSocketEvent.connected))
  }
  
  public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    subject.on(.next(WebSocketEvent.disconnected(error)))
    socket.delegate = nil
  }
  
  public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    subject.on(.next(WebSocketEvent.message(text)))
  }
  
  public func websocketDidReceiveData(socket: WebSocket, data: Data) {
    subject.on(.next(WebSocketEvent.data(data)))
  }
}
