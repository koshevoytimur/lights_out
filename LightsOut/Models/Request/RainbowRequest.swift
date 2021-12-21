//
//  RainbowRequest.swift
//  LightsOut
//
//  Created by Essence K on 20.12.2021.
//

import Foundation

struct RainbowRequest: Codable, Hashable {
  let speed: Double
  let brightness: Int

  init(speed: Double = 1, brightness: Int = 255) {
    self.speed = speed
    self.brightness = brightness
  }
}
