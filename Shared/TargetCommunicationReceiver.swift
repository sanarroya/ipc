//
//  TargetCommunicationReceiver.swift
//  IPC
//
//  Created by Santiago Avila on 30.03.21.
//

import Foundation
import Network

final class TargetCommunicationReceiver {
  let port: UInt16

  var onMessageReceived: ((Data) -> Void)?

  private var listener: NWListener

  private let listenerQueue = DispatchQueue(label: "TargetCommunicationReceiver.listener")
  private let connectionsQueue = DispatchQueue(label: "TargetCommunicationReceiver.connections")

  init(port: UInt16) {
    self.port = port
    let parameters = NWParameters.udp
    parameters.allowLocalEndpointReuse = true
    parameters.requiredLocalEndpoint = NWEndpoint.hostPort(
      host: .ipv4(.loopback),
      port: NWEndpoint.Port(rawValue: port)!
    )
    guard let listener = try? NWListener(using: parameters) else {
      fatalError("unable to create NWListener with parameters: \(parameters)")
    }
    self.listener = listener
  }

  func start() {
    listener.newConnectionHandler = { [weak self] connection in
      guard let self = self else { return }
      self.receive(connection: connection)
      connection.start(queue: self.connectionsQueue)
    }
    listener.start(queue: listenerQueue)
  }

  func stop() {
    listener.cancel()
  }

  private func receive(connection: NWConnection) {
    connection.receiveMessage { [weak self] data, _, _, error in
      guard let self = self else { return }
      if let data = data {
        DispatchQueue.main.async {
          self.onMessageReceived?(data)
        }
      }
      if let error = error {
        print("\(self) error on received message: \(error)")
        return
      }
      self.receive(connection: connection)
    }
  }
}

extension UInt16 {
  private static let privatePortsRange: ClosedRange<UInt16> = 49152...65535

  static var randomPrivatePort: UInt16 {
    privatePortsRange.randomElement()!
  }
}
