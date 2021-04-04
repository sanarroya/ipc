//
//  TargetCommunicationSender.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation
import Network

final class TargetCommunicationSender {
  let port: UInt16

  private var dataToSend: [Data] = []
  private let connection: NWConnection
  private let connectionQueue = DispatchQueue(label: "TargetCommunication.connection")
  private let dataAccessQueue = DispatchQueue(label: "TargetCommunication.eventAccess")

  init?() {
    guard let port = TargetCommunicationSender.portFromAppArguments() else { return nil }
    self.port = port
    let udpPort = NWEndpoint.Port(rawValue: self.port)!
    let parameters = NWParameters.udp
    parameters.allowLocalEndpointReuse = true
    self.connection = NWConnection(
      host: .ipv4(.loopback),
      port: udpPort,
      using: parameters
    )
    connection.start(queue: connectionQueue)
  }

  func enqueue(dataToSend data: Data) {
    dataAccessQueue.sync {
      dataToSend.append(data)
    }
    sendNext()
  }

  private func sendNext() {
    guard let data = getNextDataToSend() else { return }
    connection.send(content: data, completion: .contentProcessed { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("\(self) error on connection send: \(error)")
        return
      }
      self.sendNext()
    })
  }

  private func getNextDataToSend() -> Data? {
    return dataAccessQueue.sync {
      guard dataToSend.isNotEmpty else {
        return nil
      }
      return dataToSend.removeLast()
    }
  }
}

@available(iOS 12.0, *)
private extension TargetCommunicationSender {
  static func portFromAppArguments() -> UInt16? {
    let portPrefix = "testTrackingAutomationPort"
    guard
      let portArgument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix(portPrefix) }),
      let port = UInt16(portArgument.dropFirst(portPrefix.count))
    else {
      print("TrackingAutomationClient: No valid port found in arguments (looking for \(portPrefix)")
      return nil
    }
    return port
  }
}

extension Collection {
  var isNotEmpty: Bool {
    isEmpty == false
  }

  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
