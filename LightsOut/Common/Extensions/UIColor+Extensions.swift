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

  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
      var red: CGFloat = 0
      var green: CGFloat = 0
      var blue: CGFloat = 0
      var alpha: CGFloat = 0
      getRed(&red, green: &green, blue: &blue, alpha: &alpha)

      return (red, green, blue, alpha)
  }

  func toRGB() -> [Int] {
    var red = Int(rgba.red * rgba.alpha * 255)
    red = min(red, 255)
    red = max(red, 0)

    var blue = Int(rgba.blue * rgba.alpha * 255)
    blue = min(blue, 255)
    blue = max(blue, 0)

    var green = Int(rgba.green * rgba.alpha * 255)
    green = min(green, 255)
    green = max(green, 0)
    return [red, green, blue]
  }

  convenience init(hexRGB: String) {
    var cString:String = hexRGB.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
      self.init(red: 0, green: 0, blue: 0, alpha: CGFloat(1.0))
      return
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}
