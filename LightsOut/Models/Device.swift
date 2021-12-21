//
//  Device.swift
//  LightsOut
//
//  Created by Essence K on 29.10.2021.
//

// MARK: - testing
private let testColors = [[255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0]]

import Foundation
import Moya

struct Device: Hashable, Codable {
  let name: String
  let address: String
  var info: DeviceResponse?

  private var url: URL? {
    URL(string: "http://" + address)
  }

  func id() -> String {
    name + address
  }

  func color(color: String) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.color(ColorRequest(color: color), url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func rainbow(speed: Double = 1, brightness: Int = 255) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.rainbow(RainbowRequest(speed: speed, brightness: brightness), url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func fire(
    minBrightness: Int = 90,
    maxBrightness: Int = 255,
    msPerFrame: Int = 17
  ) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.fire(FireRequest(
      minBrightness: minBrightness,
      maxBrightness: maxBrightness,
      msPerFrame: msPerFrame
    ), url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func xmas() {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.xmas(url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func bitmap(colors: [[Int]] = testColors) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.bitmap(BitmapRequest(colors: colors), url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func information() {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.info(url)) { result in
      switch result {
      case .success(let response):
        let info = try? response.map(DeviceResponse.self)
        print(info)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }
}
