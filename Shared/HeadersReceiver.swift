//
//  HeadersReceiver.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation

final class HeadersReceiver {

  private(set) var scenarios: [Scenario] = [] {
    didSet { scenarios.forEach { print($0) } }
  }

  private var receiver: TargetCommunicationReceiver?

  init?() {
    guard let port = portFromAppArguments else { return nil }
    receiver = TargetCommunicationReceiver(port: port)
  }
}

private extension HeadersReceiver {
  func headerReceived(_ data: Data) {
    if let scenario = try? JSONDecoder().decode(Scenario.self, from: data) {
      scenarios.append(scenario)
    }
  }

  var portFromAppArguments: UInt16? {
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
