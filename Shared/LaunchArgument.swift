//
//  LaunchArgument.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import Foundation

enum LaunchArgument {
  case customScenario(port: UInt16)
}

extension LaunchArgument {
  struct Keys {
    static let customScenario = "customScenario"
  }
}

extension LaunchArgument: RawRepresentable {
  typealias RawValue = String

  init?(rawValue: String) {
    fatalError("Initialization from rawValue not expected")
  }

  var rawValue: String {
    switch self {
    case let .customScenario(port):
      return Keys.customScenario + String(port)
    }
  }
}
