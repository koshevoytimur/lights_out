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
import Combine

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

  func color(color: String, saveAsLast: Bool = true) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    let params = ColorRequest(color: color)
    if saveAsLast {
      saveMode(mode: .color, params: params)
    }
    provider.request(.color(params, url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func rainbow(_ params: RainbowRequest = RainbowRequest()) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    saveMode(mode: .rainbow, params: params)
    provider.request(.rainbow(params, url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func fire(_ params: FireRequest = FireRequest()) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    saveMode(mode: .fire, params: params)
    provider.request(.fire(params, url)) { result in
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
    saveMode(mode: .xmas)
    provider.request(.xmas(url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func bitmap(_ params: BitmapRequest) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    saveMode(mode: .bitmap, params: params)
    provider.request(.bitmap(params, url)) { result in
      switch result {
      case .success(let response):
        print(response)
      case .failure(let error):
        print(error.errorDescription ?? "Unknown error")
      }
    }
  }

  func information(completion: @escaping (Result<DeviceResponse, Error>) -> Void) {
    guard let url = self.url else { return }
    let provider = MoyaProvider<DeviceNetwork>()
    provider.request(.info(url)) { result in
      switch result {
      case .success(let response):
        guard let info = try? response.map(DeviceResponse.self) else { return }
        completion(.success(info))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func turnOff() {
    color(color: "000000", saveAsLast: false)
  }

  private func saveMode(mode: DeviceMode) {
    let store = StoreService()
    store.saveStr(mode.rawValue, key: "last_mode")
  }

  private func saveMode<T: Encodable>(mode: DeviceMode, params: T? = nil) {
    let store = StoreService()
    store.saveStr(mode.rawValue, key: "last_mode")
    store.save(params, key: "last_mode_params")
  }

  func turnOnLastMode() {
    let store = StoreService()
    guard let modeStr = store.fetchStr(key: "last_mode"),
          let mode = DeviceMode(rawValue: modeStr)
    else { return }

    switch mode {
    case .color:
      guard let params = store.fetch(ColorRequest.self, key: "last_mode_params") else { return }
      color(color: params.color)
    case .rainbow:
      guard let params = store.fetch(RainbowRequest.self, key: "last_mode_params") else { return }
      rainbow(params)
    case .fire:
      guard let params = store.fetch(FireRequest.self, key: "last_mode_params") else { return }
      fire(params)
    case .bitmap:
      guard let params = store.fetch(BitmapRequest.self, key: "last_mode_params") else { return }
      bitmap(params)
    case .xmas:
      xmas()
    case .ambi:
      return
    }
  }
}

extension Device {

}
