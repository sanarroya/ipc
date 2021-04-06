//
//  Headerinteractor.swift
//  IPC
//
//  Created by Santiago Avila Arroyave on 4/6/21.
//

import Foundation

final class HeaderInteractor {
  static let shared = HeaderInteractor()
  
  private(set) var scenarios: [Scenario]
  
  private var headersReceiver: HeadersReceiver?
  
  init() {
    headersReceiver = HeadersReceiver()
    scenarios = []
    headersReceiver?.onHeaderReceived = { self.scenarios.append($0) }
  }
  
  func pop() -> Scenario? {
    scenarios.isEmpty ? nil : scenarios.removeFirst()
  }
}
