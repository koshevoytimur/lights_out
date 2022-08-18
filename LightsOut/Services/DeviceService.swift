//
//  DeviceService.swift
//  LightsOut
//
//  Created by Essence K on 17.08.2022.
//

import Foundation
import Combine
import Moya

class DeviceService {
  public lazy var deviceFoundPublisher = deviceFoundSubject.eraseToAnyPublisher()
  private let deviceFoundSubject = PassthroughSubject<Device, Never>()

  public lazy var deviceUpdatePublisher = deviceUpdateSubject.eraseToAnyPublisher()
  private let deviceUpdateSubject = PassthroughSubject<Device?, Never>()

  // MARK: - private properties
  private let server = BonjourServer()
  private let provider = MoyaProvider<DeviceNetwork>()
  private let store = StoreService()

  // needs for developing away from rgb stripes 🥲
  private var mocked: Bool = false

  // MARK: - devices
  private(set) var devices: [Device] = []

  init() {
    server.delegate = self
  }

  func refresh() {
    server.startService()
  }

  func handleSwitchButtonPressed(device: Device) {
    device.isOn ? turnOff(device: device) : turnOnLastMode(device: device)
  }

  // TODO: - refefactor this fucking identical methods
  func color(device: Device, color: String) {
    guard let url = device.url else { return }
    let params = ColorRequest(color: color)
    if color != "000000" { saveMode(device: device, mode: .color, params: params) }
    provider.request(.color(params, url)) { [weak self] result in
      switch result {
      case .success(let response):
        self?.refreshDeviceInfo(device)
        print(response)
      case .failure(let error):
        print("🚫 ERROR:\n", error)
      }
    }
  }

  func rainbow(device: Device, _ params: RainbowRequest = RainbowRequest()) {
    guard let url = device.url else { return }
    saveMode(device: device, mode: .rainbow, params: params)
    provider.request(.rainbow(params, url)) { [weak self] result in
      switch result {
      case .success(let response):
        self?.refreshDeviceInfo(device)
        print(response)
      case .failure(let error):
        print("🚫 ERROR:\n", error)
      }
    }
  }

  func fire(device: Device, _ params: FireRequest = FireRequest()) {
    guard let url = device.url else { return }
    saveMode(device: device, mode: .fire, params: params)
    provider.request(.fire(params, url)) { [weak self] result in
      switch result {
      case .success(let response):
        self?.refreshDeviceInfo(device)
        print(response)
      case .failure(let error):
        print("🚫 ERROR:\n", error)
      }
    }
  }

  func bitmap(device: Device, _ params: BitmapRequest) {
    guard let url = device.url else { return }
    saveMode(device: device, mode: .bitmap, params: params)
    provider.request(.bitmap(params, url)) { [weak self] result in
      switch result {
      case .success(let response):
        self?.refreshDeviceInfo(device)
        print(response)
      case .failure(let error):
        print("🚫 ERROR:\n", error)
      }
    }
  }

  func xmas(device: Device) {
    guard let url = URL(string: "http://" + device.address) else { return }
    saveAsLastMode(device: device, mode: .xmas)
    provider.request(.xmas(url)) { [weak self] result in
      switch result {
      case .success(let response):
        self?.refreshDeviceInfo(device)
        print(response)
      case .failure(let error):
        print("🚫 ERROR:\n", error)
      }
    }
  }

  func turnOffAll() {
    devices
      .filter({ $0.isOn })
      .forEach({ turnOff(device: $0) })
  }

  func saveEmoji(device: Device, emoji: String) {
    store.saveStr(emoji, key: device.emojiKey)
  }

  func toggleMock() {
    mocked ? setLive() : setMocked()
  }
}

// MARK: - private functions
extension DeviceService {
  private func appendDevice(name: String, address: String) {
    guard !devices.contains(where: { $0.address == address }) else { return }

    guard let url = URL(string: "http://" + address) else { return }

    provider.request(.info(url)) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        guard let info = try? response.map(DeviceResponse.self) else { return }
        let device = Device(name: name, address: address, info: info)
        self.devices.append(device)
        self.deviceFoundSubject.send(device)
      case .failure(let error):
        let device = Device(name: name, address: address)
        self.devices.append(device)
        self.deviceFoundSubject.send(device)
        print("🚫 ERROR:\n", error)
        print("📇 ADRESS:\n", address)
      }
    }
  }

  private func refreshDeviceInfo(_ device: Device) {
    guard let url = device.url else { return }
    provider.request(.info(url)) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        guard let info = try? response.map(DeviceResponse.self) else { return }
        device.info = info
        self.deviceUpdateSubject.send(device)
      case .failure(let error):
        print("🚫 ERROR:\n", error)
      }
    }
  }

  private func saveAsLastMode(device: Device, mode: DeviceMode) {
    store.saveStr(mode.rawValue, key: device.lastModeKey)
  }

  private func saveMode<T: Encodable>(device: Device, mode: DeviceMode, params: T? = nil) {
    store.saveStr(mode.rawValue, key: device.lastModeKey)
    store.save(params, key: device.lastModeParamsKey)
  }

  private func turnOff(device: Device) {
    color(device: device, color: "000000")
  }

  private func turnOnLastMode(device: Device) {
    guard let modeStr = store.fetchStr(key: device.lastModeKey),
          let mode = DeviceMode(rawValue: modeStr) else {
      rainbow(device: device)
      return
    }

    switch mode {
    case .color:
      guard let params = store.fetch(ColorRequest.self, key: device.lastModeParamsKey) else { return }
      color(device: device, color: params.color)
    case .rainbow:
      guard let params = store.fetch(RainbowRequest.self, key: device.lastModeParamsKey) else { return }
      rainbow(device: device, params)
    case .fire:
      guard let params = store.fetch(FireRequest.self, key: device.lastModeParamsKey) else { return }
      fire(device: device, params)
    case .bitmap:
      guard let params = store.fetch(BitmapRequest.self, key: device.lastModeParamsKey) else { return }
      bitmap(device: device, params)
    case .xmas:
      return
    case .ambi:
      return
    case .disabled:
      return
    case .unknown:
      return
    }
  }

  private func fetchEmoji(device: Device) -> String? {
    return store.fetchStr(key: device.emojiKey)
  }

  private func setMocked() {
    mocked = true
    devices = Mock.devices
    deviceUpdateSubject.send(nil)
  }

  private func setLive() {
    mocked = false
    devices = []
    refresh()
    deviceUpdateSubject.send(nil)
  }
}

// MARK: - bonjorno delegate
extension DeviceService: BonjourServerDelegate {
  func didResolveAddress(name: String, address: String) {
    print("🥶", name)
    appendDevice(name: name, address: address)
  }
}
