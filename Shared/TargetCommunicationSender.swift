//
//  TargetCommunicationSender.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation
import Network
import os.log

final class TargetCommunicationSender {
  let port: UInt16

  private var dataToSend: [Data] = []
  private let connection: NWConnection
  private let connectionQueue = DispatchQueue(label: "TargetCommunication.connection")
  private let dataAccessQueue = DispatchQueue(label: "TargetCommunication.eventAccess")

  init(port: UInt16) {
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
      guard let scenario = try? JSONDecoder().decode(Scenario.self, from: data) else {
        return
      }
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

extension Collection {
  var isNotEmpty: Bool {
    isEmpty == false
  }

  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
