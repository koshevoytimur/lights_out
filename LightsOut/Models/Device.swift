//
//  Device.swift
//  LightsOut
//
//  Created by Essence K on 29.10.2021.
//

// MARK: - testing
private let testColors = [[255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0]]

import Foundation

struct Device: Hashable, Codable {
  let name: String
  let address: String
  var leds: [Led]
  
  func id() -> String {
    name + address
  }

  struct Led: Hashable, Codable {
    var color: String
  }

  func color(color: String) {
    Task {
      try await NetworkService().requestColor(for: self, color: color)
    }
  }

  func bitmap(colors: [[Int]] = testColors) {
    Task {
      try await NetworkService().requestBitmap(for: self, colors: colors)
    }
  }
}
