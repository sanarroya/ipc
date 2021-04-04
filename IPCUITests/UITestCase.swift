//
//  UITestCase.swift
//  IPC
//
//  Created by Santiago Avila on 04.04.21.
//

import XCTest

class UITestCase: XCTestCase {

  var app = XCUIApplication()
  var launchArguments: [LaunchArgument] {
    [.customScenario(port: port)]
  }

  private let port = UInt16.randomPrivatePort

  func launchApp() {
    app.launchArguments += launchArguments.map { $0.rawValue }
  }

  override func setUp() {
    super.setUp()
    launchApp()
  }

  override func tearDown() {
    super.tearDown()
    app.terminate()
  }
}
