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
  var name: String
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

  var lastModeKey: String { "\(name)last-mode" }

  var lastModeParamsKey: String { "\(name)last-mode-params" }

  var emojiKey: String { "\(name)-emoji" }

  var url: URL? { URL(string: "http://" + address) }

  var emoji: String? { StoreService().fetchStr(key: emojiKey) }

  // TODO: - make disabled mode directly in the device's firmware and stop using this workaround.... sometime
  var isOn: Bool {
    let isBlack = info?.mode != .disabled && info?.settings?.color != "000000"
    let isDisabled = info?.mode == .disabled
    return isBlack || isDisabled
  }
}
