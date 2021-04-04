//
//  HeadersSender.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation

final class HeadersSender {

  static let shared = HeadersSender()

  private let sender = TargetCommunicationSender()

  func send(scenario: Scenario) {
    guard let data = try? JSONEncoder().encode(scenario) else { return }
    sender?.enqueue(dataToSend: data)
  }
}
