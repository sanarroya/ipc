//
//  HeadersReceiver.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation

final class HeadersReceiver {

  var onHeaderReceived: ((Scenario) -> Void)?
  
  private var receiver: TargetCommunicationReceiver?

  init() {
    receiver = TargetCommunicationReceiver()
    receiver?.onMessageReceived = { self.headerReceived($0) }
    receiver?.start()
  }
}

private extension HeadersReceiver {
  func headerReceived(_ data: Data) {
    print("HeadersReceiver receiving...")
    if let scenario = try? JSONDecoder().decode(Scenario.self, from: data) {
      print("Received: Scenario->\(scenario.name) Path->\(scenario.path)")
      onHeaderReceived?(scenario)
    }
  }
}
