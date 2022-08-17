//
//  FireRequest.swift
//  LightsOut
//
//  Created by Essence K on 20.12.2021.
//

import Foundation

struct FireRequest: Codable, Hashable {

  let minBrightness: Int
  let maxBrightness: Int
  let msPerFrame: Int

  init(
    minBrightness: Int = 70,
    maxBrightness: Int = 255,
    msPerFrame: Int = 50
  ) {
    self.minBrightness = minBrightness
    self.maxBrightness = maxBrightness
    self.msPerFrame = msPerFrame
  }
}
