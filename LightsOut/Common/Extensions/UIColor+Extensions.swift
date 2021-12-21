//
//  UIColor+Extensions.swift
//  LightsOut
//
//  Created by Essence K on 04.11.2021.
//

import UIKit

extension UIColor {
  func mix(with color: UIColor, amount: CGFloat) -> Self {
    var red1: CGFloat = 0
    var green1: CGFloat = 0
    var blue1: CGFloat = 0
    var alpha1: CGFloat = 0

    var red2: CGFloat = 0
    var green2: CGFloat = 0
    var blue2: CGFloat = 0
    var alpha2: CGFloat = 0

    getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
    color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

    return Self(
      red: red1 * CGFloat(1.0 - amount) + red2 * amount,
      green: green1 * CGFloat(1.0 - amount) + green2 * amount,
      blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
      alpha: alpha1
    )
  }

  func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
  func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }

  func hexString() -> String {
    let components = self.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    print(hexString)
    return hexString
  }
}
