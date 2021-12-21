//
//  DeviceResponse.swift
//  LightsOut
//
//  Created by Essence K on 08.11.2021.
//

import Foundation
import Moya

struct DeviceResponse: Codable, Hashable {
  let name: String
  let numLeds: Int
  let mode: DeviceMode
  let type: DeviceType
  let settings: Settings?

  struct Settings: Codable, Hashable {
    // color
    let color: String?

    // rainbow
    let speed: Double?
    let brightness: Int?

    // fire
    let minBrightness: Int?
    let maxBrightness: Int?
    let msPerFrame: Int?
  }
}

enum DeviceMode: String, Codable, Hashable, CaseIterable {
  case color
  case rainbow
  case fire
  case bitmap
  case xmas
  case ambi

  var title: String {
    switch self {
    case .color:
      return "Color"
    case .rainbow:
      return "Rainbow"
    case .fire:
      return "Fire"
    case .bitmap:
      return "Bitmap"
    case .xmas:
      return "Xmas"
    case .ambi:
      return "Ambilight"
    }
  }
}

enum DeviceType: String, Codable, Hashable {
  case ledStrip = "led-srip"
  case matrix

  var title: String {
    switch self {
    case .ledStrip:
      return "Led Stripe"
    case .matrix:
      return "Minecraft"
    }
  }
}
