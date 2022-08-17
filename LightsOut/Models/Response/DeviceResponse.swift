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
  case disabled
  case unknown

  var title: String {
    switch self {
    case .color:
      return "color"
    case .rainbow:
      return "rainbow"
    case .fire:
      return "fire"
    case .bitmap:
      return "bitmap"
    case .xmas:
      return "xmas"
    case .ambi:
      return "ambilight"
    case .disabled:
      return "disabled"
    case .unknown:
      return "unknown"
    }
  }

  var emoji: String {
    switch self {
    case .color:
      return "🎨"
    case .rainbow:
      return "🌈"
    case .fire:
      return "🔥"
    case .bitmap:
      return "🚥"
    case .xmas:
      return "🎄"
    case .ambi:
      return "🖥"
    case .disabled:
      return "⬛️"
    case .unknown:
      return "❓"
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
