//
//  TargetCommunicationReceiver.swift
//  IPC
//
//  Created by Santiago Avila on 30.03.21.
//

import Foundation
import Network

final class TargetCommunicationReceiver {

  var onMessageReceived: ((Data) -> Void)?

  private var listener: NWListener

  private let listenerQueue = DispatchQueue(label: "TargetCommunicationReceiver.listener")
  private let connectionsQueue = DispatchQueue(label: "TargetCommunicationReceiver.connections")

  init?() {
    guard let port = TargetCommunicationReceiver.portFromAppArguments() else { return nil }
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

      if let _ = error {
        return
      }
      self.receive(connection: connection)
    }
  }
}

private extension TargetCommunicationReceiver {
  static func portFromAppArguments() -> UInt16? {
    let portPrefix = "customScenario"
    ProcessInfo.processInfo.arguments.forEach {
      print($0)
    }
    guard
      let portArgument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix(portPrefix) }),
      let port = UInt16(portArgument.dropFirst(portPrefix.count))
    else {
      print("TargetCommunicationSender: No valid port found in arguments (looking for \(portPrefix)")
      return nil
    }
    return port
  }
}

extension UInt16 {
  private static let privatePortsRange: ClosedRange<UInt16> = 49152...65535

  static var randomPrivatePort: UInt16 {
    privatePortsRange.randomElement()!
  }
}
