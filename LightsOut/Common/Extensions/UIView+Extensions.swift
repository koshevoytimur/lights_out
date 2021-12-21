//
//  UIView+Extensions.swift
//  LightsOut
//
//  Created by Essence K on 04.11.2021.
//

import UIKit

extension UIView {
  static func wrapView(_ view: UIView, borderWidth: CGFloat = 8) -> UIView {
    view.translatesAutoresizingMaskIntoConstraints = false
    let contentView = UIView()
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = view.backgroundColor?.darker()
    contentView.layer.cornerRadius = view.layer.cornerRadius
    contentView.addSubview(view)
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: borderWidth),
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: borderWidth),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -borderWidth),
      view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -borderWidth),
    ])
    return contentView
  }

  static func wrap(_ view: UIView, borderWidth: CGFloat = 8) -> UIView {
    view.translatesAutoresizingMaskIntoConstraints = false
    let contentView = UIView()
    contentView.frame = .init(x: view.frame.minX, y: view.frame.minY, width: view.frame.width + borderWidth, height: view.frame.height + borderWidth)
    view.center = .init(x: view.center.x + borderWidth / 2, y: view.center.y + borderWidth / 2)
    contentView.backgroundColor = view.backgroundColor?.darker()
    contentView.layer.cornerRadius = view.layer.cornerRadius
    contentView.addSubview(view)
    return contentView
  }
}

extension UIStackView {
  func setMargins(_ size: CGFloat) {
    isLayoutMarginsRelativeArrangement = true
    directionalLayoutMargins = .init(top: size, leading: size, bottom: size, trailing: size)
  }
}
