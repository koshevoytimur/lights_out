//
//  Colors.swift
//  LightsOut
//
//  Created by Essence K on 16.08.2022.
//

import UIKit

enum Theme {
  case dark
}

// MARK: - colors
extension Theme {
  var primaryColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 24.0/255.0, green: 24.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    }
  }

  var secondaryColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    }
  }

  var backgroundColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 38.0/255.0, green: 38.0/255.0, blue: 38.0/255.0, alpha: 1.0)
    }
  }

  var primaryTextColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    }
  }

  var secondaryTextColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 1.0)
    }
  }
}

// MARK: - fonts
extension Theme {
  var font10: UIFont {
    switch self {
    case .dark:
      return UIFont(name: "ComicSansMS", size: 10) ?? .systemFont(ofSize: 10)
    }
  }

  var font12: UIFont {
    switch self {
    case .dark:
      return UIFont(name: "ComicSansMS", size: 12) ?? .systemFont(ofSize: 12)
    }
  }

  var font14: UIFont {
    switch self {
    case .dark:
      return UIFont(name: "ComicSansMS", size: 14) ?? .systemFont(ofSize: 14)
    }
  }

  var font16: UIFont {
    switch self {
    case .dark:
      return UIFont(name: "ComicSansMS", size: 16) ?? .systemFont(ofSize: 16)
    }
  }

  var font18: UIFont {
    switch self {
    case .dark:
      return UIFont(name: "ComicSansMS", size: 18) ?? .systemFont(ofSize: 18)
    }
  }

  var font20: UIFont {
    switch self {
    case .dark:
      return UIFont(name: "ComicSansMS", size: 20) ?? .systemFont(ofSize: 20)
    }
  }
}
