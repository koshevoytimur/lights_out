//
//  NetworkService.swift
//  LightsOut
//
//  Created by Essence K on 28.10.2021.
//

import Foundation
import UIKit

fileprivate enum Method: String {
  case post = "POST"
  case get = "GET"
}

class NetworkService {
  private func makeRequest(url: URL, body: Data, method: Method) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpBody = body
    request.httpMethod = method.rawValue
    request.setValue(
      "application/x-www-form-urlencoded",
      forHTTPHeaderField: "Content-Type"
    )
    return request
  }

  func requestBitmap(for device: Device, colors: [[Int]]) async throws {
    guard let url = URL(string: "http://" + device.address + "/bitmap/") else { return }
    guard let body = "data=\(colors)".data(using: .utf8) else { return }
    let request = makeRequest(url: url, body: body, method: .post)
    let _ = try await URLSession.shared.data(for: request)
  }

  func requestColor(for device: Device, color: String) async throws {
    guard let url = URL(string: "http://" + device.address + "/color/") else { return }
    guard let body = "color=\(color)".data(using: .utf8) else { return }
    let request = makeRequest(url: url, body: body, method: .post)
    let _ = try await URLSession.shared.data(for: request)
  }
}
