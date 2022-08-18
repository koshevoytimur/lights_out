//
//  ModeCollectionViewCell.swift
//  LightsOut
//
//  Created by Essence K on 17.08.2022.
//

import UIKit

class ModeCollectionViewCell: UICollectionViewCell, ReusableCell {

  private let padding: CGFloat = 8
  private let theme: Theme = .dark
  private var mode: DeviceMode = .unknown

  private lazy var emojiLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 24)
    label.minimumScaleFactor = 0.5
    label.adjustsFontSizeToFitWidth = true
    label.textColor = theme.primaryTextColor
    return label
  }()
  private lazy var cornerRadius: CGFloat = padding * 1.5
  private lazy var selectedColor = theme.secondaryColor
  private lazy var deselectedColor = theme.primaryColor

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
//    contentView.addDashedBorder(cornerRadius: cornerRadius)
    contentView.addDashedBorder(strokeColor: theme.backgroundColor.cgColor, cornerRadius: cornerRadius)
  }

  private func setup() {
    setupView()
  }

  private func setupView() {
    contentView.rounded(cornerRadius)
//    contentView.backgroundColor = theme.secondaryColor
    setupEmojiLabel()
  }

  private func setupEmojiLabel() {
    contentView.addSubview(
      emojiLabel,
      withEdgeInsets: .init(top: padding, left: padding, bottom: padding, right: padding)
    )
  }

  func update(mode: DeviceMode) {
    self.mode = mode
    emojiLabel.text = mode.emoji
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ModeCollectionViewCell {
  func setSelected(_ isSelected: Bool) {
    self.isSelected = isSelected
    contentView.backgroundColor = isSelected ? selectedColor : deselectedColor
  }
}
