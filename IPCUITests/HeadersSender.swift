//
//  HeadersSender.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation

final class HeadersSender {

  static let shared = HeadersSender()

  private var sender: TargetCommunicationSender?
  
  func initIPC(withPort port: UInt16) {
    sender = TargetCommunicationSender(port: port)
  }

  func send(scenario: Scenario) {
    guard let data = try? JSONEncoder().encode(scenario) else { return }
    sender?.enqueue(dataToSend: data)
  }
}
