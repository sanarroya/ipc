//
//  ViewController.swift
//  IPC
//
//  Created by temporaryadmin on 04.04.21.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet private weak var headerLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
      guard let scenario = HeaderInteractor.shared.pop() else {
        self.headerLabel.text = "No headers"
        return
      }
      self.headerLabel.text = "Scenario: \(scenario.name), Path: \(scenario.path)"
//      sleep(10)
    }
  }
}

