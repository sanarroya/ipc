//
//  ViewTest.swift
//  IPCUITests
//
//  Created by Santiago Avila on 04.04.21.
//

import XCTest
import Foundation

final class ViewTest: UITestCase {

  func testSender() {
    headersSender.send(scenario: Constants.scenario)
    XCTAssertEqual("", String())
  }
}

extension ViewTest {
  struct Constants {
    static let scenario = Scenario(name: "name", path: "path")
  }
}
