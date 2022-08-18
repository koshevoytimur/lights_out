//
//  MainTableViewCell.swift
//  LightsOut
//
//  Created by Essence K on 30.07.2022.
//

import UIKit
import Combine

class MainTableViewCell: UITableViewCell, ReusableCell {

  // TODO: - make this crap not hardcoded sometime
  private let theme: Theme = .dark

  private var device: Device? = nil

  private let padding: CGFloat = 8

  private lazy var cardView: UIView = {
    let view = UIView()
    view.backgroundColor = theme.primaryColor
    view.rounded(padding * 4)
    view.layer.masksToBounds = true
    return view
  }()
  private lazy var circleView: UIView = {
    let view = UIView()
    view.backgroundColor = theme.backgroundColor
    view.rounded(padding * 4)
    return view
  }()
  private lazy var dashContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  private(set) lazy var emojiTextField: UITextField = {
    let text = UITextField()
    text.textAlignment = .center
    text.font = .systemFont(ofSize: 30)
    text.adjustsFontSizeToFitWidth = true
    text.textColor = theme.primaryTextColor
    return text
  }()
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .natural
    label.font = theme.font20
    label.minimumScaleFactor = 0.5
    label.adjustsFontSizeToFitWidth = true
    label.textColor = theme.primaryTextColor
    return label
  }()
  private lazy var modeLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .natural
    label.font = theme.font14
    label.minimumScaleFactor = 0.5
    label.adjustsFontSizeToFitWidth = true
    label.textColor = theme.primaryTextColor
    return label
  }()
  private(set) lazy var switchView: SwitchView = {
    let switchView = SwitchView(size: .init(width: padding * 3, height: padding * 6))
    switchView.translatesAutoresizingMaskIntoConstraints = false
    return switchView
  }()
  private lazy var shortcutsContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.rounded(shortcutsCornerRadius)
    return view
  }()
  private let shortcutsCornerRadius: CGFloat = 15

  var cancellables = Set<AnyCancellable>()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    device = nil
    titleLabel.text = ""
    emojiTextField.text = ""
    modeLabel.text = ""
    cancellables.removeAll()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dashContentView.addDashedBorder(cornerRadius: padding * 4)
    let space = NSNumber(value: Float((shortcutsContentView.frame.width * 0.3) / 16))
    let dash = NSNumber(value: Float((shortcutsContentView.frame.width * 0.6) / 16))
    shortcutsContentView.addDashedBorder(
      strokeColor: theme.secondaryColor.cgColor,
      lineDashPattern: [space, dash],
      cornerRadius: shortcutsCornerRadius
    )
    contentView.bringSubviewToFront(modeLabel)
  }

  private func setup() {
    setupView()
  }

  private func setupView() {
    contentView.backgroundColor = theme.backgroundColor
    setupCardView()
    setupCircleView()
    setupDashedContentView()
    setupEmojiView()
    setupSwitchView()
    setupTitleLabel()
    setupModeLabel()
    setupShortcutContentView()
  }

  private func setupCardView() {
    contentView.addSubview(
      cardView,
      withEdgeInsets: .init(
        top: padding,
        left: padding * 5,
        bottom: padding,
        right: padding * 3
      )
    )
  }

  private func setupCircleView() {
    contentView.addSubview(
      circleView,
      constraints: [
        circleView.heightAnchor.constraint(equalToConstant: padding * 8),
        circleView.widthAnchor.constraint(equalToConstant: padding * 8),
        circleView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        circleView.centerXAnchor.constraint(equalTo: cardView.leadingAnchor)
      ]
    )
  }

  private func setupDashedContentView() {
    circleView.addSubview(
      dashContentView,
      constraints: [
        dashContentView.heightAnchor.constraint(equalToConstant: padding * 6.5),
        dashContentView.widthAnchor.constraint(equalToConstant: padding * 6.5),
        dashContentView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
        dashContentView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor)
      ]
    )
  }

  private func setupEmojiView() {
    dashContentView.addSubview(
      emojiTextField,
      constraints: [
        emojiTextField.topAnchor.constraint(equalTo: dashContentView.topAnchor, constant: 4),
        emojiTextField.leadingAnchor.constraint(equalTo: dashContentView.leadingAnchor, constant: 4),
        emojiTextField.trailingAnchor.constraint(equalTo: dashContentView.trailingAnchor, constant: -4),
        emojiTextField.bottomAnchor.constraint(equalTo: dashContentView.bottomAnchor, constant: -4)
      ]
    )
  }

  private func setupSwitchView() {
    cardView.addSubview(
      switchView,
      constraints: [
        switchView.heightAnchor.constraint(equalToConstant: padding * 6),
        switchView.widthAnchor.constraint(equalToConstant: padding * 3),
        switchView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding),
        switchView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -padding * 2)
      ]
    )
  }

  private func setupTitleLabel() {
    cardView.addSubview(
      titleLabel,
      constraints: [
        titleLabel.heightAnchor.constraint(equalToConstant: padding * 4),
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: padding * 6.5),
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding * 0.75),
        titleLabel.trailingAnchor.constraint(equalTo: switchView.leadingAnchor, constant: padding)
      ]
    )
  }

  private func setupModeLabel() {
    cardView.addSubview(
      modeLabel,
      constraints: [
        modeLabel.heightAnchor.constraint(equalToConstant: padding * 3),
        modeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        modeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
        modeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
      ]
    )
  }

  private func setupShortcutContentView() {
    cardView.addSubview(
      shortcutsContentView,
      constraints: [
        shortcutsContentView.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: padding),
        shortcutsContentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        shortcutsContentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -padding * 2),
        shortcutsContentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -padding * 2)
      ]
    )
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - public function
extension MainTableViewCell {
  public func update(device: Device) {
    self.device = device
    titleLabel.text = device.name
    emojiTextField.text = device.emoji ?? "🍉"
    modeLabel.text = device.isOn ? "\(device.info?.mode.title ?? "") \(device.info?.mode.emoji ?? "")" : "disabled"
    switchView.setIsOn(isOn: device.isOn)
  }
}
