//
//  StoreService.swift.swift
//  LightsOut
//
//  Created by Essence K on 29.10.2021.
//

import Foundation

class StoreService {
  private let defaults = UserDefaults.standard

  func save<T: Encodable>(_ obj: T, key: String) {
    defaults.set(try? PropertyListEncoder().encode(obj), forKey: key)
  }

  func fetch<T: Decodable>(_ type: T.Type, key: String) -> T? {
    guard let data =  defaults.object(forKey: key) as? Data else { return nil }
    return try? PropertyListDecoder().decode(T.self, from: data)
  }

  func delete(key: String) {
    defaults.removeObject(forKey: key)
  }
}
