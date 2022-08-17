//
//  Device.swift
//  LightsOut
//
//  Created by Essence K on 29.10.2021.
//

import Foundation
import Moya
import Combine

class Device {
  let name: String
  let address: String
  var info: DeviceResponse? = .none

  init(
    name: String,
    address: String,
    info: DeviceResponse? = .none
  ) {
    self.name = name
    self.address = address
    self.info = info
  }

  public var lastModeKey: String {
    return "\(name)last-mode"
  }

  public var lastModeParamsKey: String {
    return "\(name)last-mode-params"
  }

  public var emojiKey: String {
    return "\(name)-emoji"
  }

  public var url: URL? {
    URL(string: "http://" + address)
  }

  public var emoji: String? {
    StoreService().fetchStr(key: emojiKey)
  }

  // TODO: - make disabled mode directly in the device's firmware and stop using this workaround.... sometime
  public var isOn: Bool {
    (info?.mode != .disabled && info?.settings?.color != "000000") || info?.mode == .disabled
  }
}
