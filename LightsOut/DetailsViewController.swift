//
//  DetailsViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

import UIKit

class DetailsViewController: ViewController {

  let device: Device

  init(device: Device) {
    self.device = device
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Initializing Color Picker
    let picker = UIColorPickerViewController()

    // Setting the Initial Color of the Picker
    picker.selectedColor = self.view.backgroundColor!

    // Setting Delegate
    picker.delegate = self

    // Presenting the Color Picker
    self.present(picker, animated: true, completion: nil)
  }
}
