//
//  DeviceDetailsHeaderView.swift
//  LightsOut
//
//  Created by Essence K on 21.12.2021.
//

import UIKit
import Combine
import CombineCocoa


class DeviceDetailsHeaderView: UIView {
  struct Props {
    let title: String
    let mode: String
    let numLeds: Int
  }

  var turnOnPublisher: AnyPublisher<Void, Never> {
    turnOn.tapPublisher.eraseToAnyPublisher()
  }

  var turnOffPublisher: AnyPublisher<Void, Never> {
    turnOff.tapPublisher.eraseToAnyPublisher()
  }

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .natural
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()
  private lazy var modeLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .natural
    label.font = .boldSystemFont(ofSize: 12)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()
  private lazy var numLedsLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .natural
    label.font = .boldSystemFont(ofSize: 12)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()
  private lazy var turnOn: UIButton = {
    let button = UIButton()
    button.configuration = .tinted()
    button.configuration?.cornerStyle = .dynamic
    button.configuration?.baseBackgroundColor = .systemGreen
    button.configuration?.baseForegroundColor = .black
    button.configuration?.image = UIImage(systemName: "play.fill")
    return button
  }()
  private lazy var turnOff: UIButton = {
    let button = UIButton()
    button.configuration = .tinted()
    button.configuration?.cornerStyle = .dynamic
    button.configuration?.baseBackgroundColor = .systemRed
    button.configuration?.baseForegroundColor = .black
    button.configuration?.image = UIImage(systemName: "pause.fill")
    return button
  }()
  private lazy var buttonsStack = createStackView(color: .clear, axis: .vertical)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  private func setupView() {
    rounded(8)
    backgroundColor = .lightGray.withAlphaComponent(0.3)
    setupTitleLabel()
    setupModeLabel()
    setupButtons()
    setupNumLedsLabel()
  }

  private func setupTitleLabel() {
    addSubview(titleLabel, leading: 10, top: 20)
  }

  private func setupModeLabel() {
    addSubview(modeLabel, constraints: [
      modeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
      modeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
    ])
  }

  private func setupNumLedsLabel() {
    addSubview(numLedsLabel, constraints: [
      numLedsLabel.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8),
      numLedsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      numLedsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
    ])
  }

  private func setupButtons() {
    addSubview(buttonsStack, trailing: 10, top: 10, bottom: 10, width: 70)
    buttonsStack.addArrangedSubview(turnOn)
    buttonsStack.addArrangedSubview(turnOff)
  }

  public func render(props: Props) {
    titleLabel.text = props.title
    modeLabel.text = "Current mode: " + props.mode
    numLedsLabel.text = "Number of leds: " + "\(props.numLeds)"
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
