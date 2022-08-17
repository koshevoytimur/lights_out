//
//  MainTableViewCell.swift
//  LightsOut
//
//  Created by Essence K on 30.07.2022.
//

import UIKit
import Combine

class MainTableViewCell: UITableViewCell, ReusableCell {

  // MARK: - Public properties
  public lazy var switchButtonTapPublisher = switchButtonTapSubject.eraseToAnyPublisher()
  private let switchButtonTapSubject = PassthroughSubject<Device, Never>()

  public lazy var emojiTextFieldReturnPublisher = emojiTextFieldReturnSubject.eraseToAnyPublisher()
  private let emojiTextFieldReturnSubject = PassthroughSubject<String, Never>()

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
  private lazy var emojiTextField: UITextField = {
    let label = UITextField()
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 30)
    label.adjustsFontSizeToFitWidth = true
    label.textColor = theme.primaryTextColor
    return label
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
  private lazy var switchButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: "switch-on"), for: .normal)
    return button
  }()

  private var cancellable = Set<AnyCancellable>()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
    setupBindings()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dashContentView.addDashedCircle()
    contentView.bringSubviewToFront(modeLabel)
  }

  private func setupView() {
    contentView.backgroundColor = theme.backgroundColor
    setupCardView()
    setupCircleView()
    setupDashedContentView()
    setupEmojiView()
    setupTitleLabel()
    setupModeLabel()
    setupSwitchButton()
  }

  private func setupBindings() {
    switchButton.tapPublisher.sink { [weak self] _ in
      guard let self = self, let device = self.device else { return }
      self.switchButtonTapSubject.send(device)
      let generator = UIImpactFeedbackGenerator(style: self.device?.isOn ?? true ? .light : .medium)
      generator.impactOccurred()
    }.store(in: &cancellable)

    emojiTextField.returnPublisher.sink { [weak self] _ in
      guard let self = self else { return }
      self.emojiTextFieldReturnSubject.send(self.emojiTextField.text ?? "")
      self.emojiTextField.endEditing(true)
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)
    }.store(in: &cancellable)
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

  private func setupTitleLabel() {
    cardView.addSubview(
      titleLabel,
      constraints: [
        titleLabel.heightAnchor.constraint(equalToConstant: padding * 4),
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: padding * 7),
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding * 1.5),
        titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -padding * 2)
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

  private func setupDescriptionLabel() {
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

  private func setupSwitchButton() {
    cardView.addSubview(
      switchButton,
      constraints: [
        switchButton.heightAnchor.constraint(equalToConstant: padding * 4),
        switchButton.widthAnchor.constraint(equalToConstant: padding * 4),
        switchButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -padding * 2),
        switchButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -padding * 2)
      ]
    )
  }

  private func setButtonImage(isOn: Bool) {
    let imageName = isOn ? "switch-on" : "switch-off"
    switchButton.setImage(UIImage(named: imageName), for: .normal)
  }

  public func update(device: Device) {
    self.device = device
    titleLabel.text = device.name
    emojiTextField.text = device.emoji ?? "🍉"
    modeLabel.text = device.isOn ? "\(device.info?.mode.title ?? "") \(device.info?.mode.emoji ?? "")" : "--------"
    setButtonImage(isOn: device.isOn)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
