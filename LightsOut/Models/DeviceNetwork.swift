//
//  DeviceNetwork.swift
//  LightsOut
//
//  Created by Essence K on 20.12.2021.
//

import Foundation
import Moya

enum DeviceNetwork {
  case info(URL)
  case color(ColorRequest, URL)
  case rainbow(RainbowRequest, URL)
  case fire(FireRequest, URL)
  case bitmap(BitmapRequest, URL)
  case xmas(URL)
}

extension DeviceNetwork: TargetType {
  var baseURL: URL {
    switch self {
    case .info(let url), .xmas(let url), .color(_ , let url), .rainbow(_ , let url), .fire(_ , let url), .bitmap(_ , let url):
      return url
    }
  }

  var path: String {
    switch self {
    case .info:
      return ""
    case .color:
      return "/color/"
    case .rainbow:
      return "/rainbow/"
    case .fire:
      return "/fire/"
    case .bitmap:
      return "/bitmap/"
    case .xmas:
      return "/xmas/"
    }
  }

  var method: Moya.Method {
    switch self {
    case .info:
      return .get
    default:
      return .post
    }
  }

  var task: Task {
    switch self {
    case .info:
      return .requestPlain
    case .color(let model, _):
      return .requestJSONEncodable(model)
    case .rainbow(let model, _):
      return .requestJSONEncodable(model)
    case .fire(let model, _):
      return .requestJSONEncodable(model)
    case .bitmap(let model, _):
      return .requestJSONEncodable(model.colors)
    case .xmas:
      return .requestPlain
    }
  }

  var headers: [String : String]? {
    return [
        "Content-Type": "application/json",
        "Accept-Type": "application/json"
    ]
  }
}
