//
//  Button.swift
//  LightsOut
//
//  Created by Essence K on 02.11.2021.
//

import UIKit

class Button: UIButton {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    setupView()
  }

  private func setupView() {

  }
}
