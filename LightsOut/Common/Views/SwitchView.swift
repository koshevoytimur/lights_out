//
//  SwitchView.swift
//  LightsOut
//
//  Created by Essence K on 18.08.2022.
//

import UIKit
import Combine

class SwitchView: UIView {

  public lazy var isOnPublisher = isOnSubject.eraseToAnyPublisher()
  private let isOnSubject = PassthroughSubject<Bool, Never>()

  private let padding: CGFloat = 8

  private let theme: Theme = .dark

  private var backgroundViewColor: UIColor {
    theme.primaryColor
//    theme.backgroundColor
  }

  private var backgroundViewBorderColor: UIColor {
    theme.secondaryColor
  }

  private var dotViewColor: UIColor {
    theme.backgroundColor
//    theme.secondaryColor.withAlphaComponent(0.75)
  }

  private var dotViewBorderColor: UIColor {
    isOn ? .systemGreen.withAlphaComponent(0.3) : .systemRed.withAlphaComponent(0.3)
  }

  private lazy var backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = backgroundViewColor
    view.bordered(borderColor: backgroundViewBorderColor, borderWidth: 2)
    return view
  }()
  private lazy var dotView: UIView = {
    let view = UIView()
    view.backgroundColor = dotViewColor
    view.bordered(borderColor: dotViewBorderColor, borderWidth: 1)
    view.clipsToBounds = true
    return view
  }()
  private var dotSize: CGSize {
    .init(
      width: size.width - padding / 2,
      height: size.width - padding / 2
    )
  }
  private lazy var dotViewTopConstraint: NSLayoutConstraint = dotView.topAnchor.constraint(
    equalTo: backgroundView.topAnchor,
    constant: padding / 2
  )

  private lazy var dotViewBottomConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(
    equalTo: backgroundView.centerYAnchor
  )

  private let size: CGSize

  private var isOn: Bool = true

  init(size: CGSize) {
    self.size = size
    super.init(frame: .zero)
    setupView()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundView.layer.cornerRadius = size.width / 2
//    backgroundView.addDashedBorder(
//      strokeColor: backgroundViewBorderColor.withAlphaComponent(0.1).cgColor,
//      lineWidth: 1.5,
//      lineDashPattern: [2, 3, 1, 4],
//      cornerRadius: size.width / 2
//    )
    dotView.layer.cornerRadius = (size.width - padding / 2) / 2
  }

  private func setupView() {
    backgroundColor = .clear
    isUserInteractionEnabled = true
    setupBackgroundView()
    setupDotView()
    setupGestureRecognizer()
  }

  private func setupBackgroundView() {
    addSubview(backgroundView, withEdgeInsets: .init(top: 0, left: 0, bottom: 0, right: 0))
  }

  private func setupDotView() {
    backgroundView.addSubview(
      dotView,
      constraints: [
        dotViewTopConstraint,
        dotView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: padding / 4),
        dotView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -padding / 4),
        dotViewBottomConstraint
      ]
    )
  }

  private func setupGestureRecognizer() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleToggle))
    addGestureRecognizer(tap)
  }

  private func setOn(animated: Bool = false) {
    if animated {
      isUserInteractionEnabled = false
      UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
          self.dotViewTopConstraint.constant = self.padding / 2
          self.backgroundView.layoutSubviews()
        }
        UIView.addKeyframe(withRelativeStartTime:0.4, relativeDuration: 0.2) {
          self.dotView.layer.borderColor = self.dotViewBorderColor.cgColor
          self.backgroundView.layoutSubviews()
        }
        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
          self.dotViewBottomConstraint.constant = 0
          self.backgroundView.layoutSubviews()
        }
        self.isUserInteractionEnabled = true
      })
    } else {
      dotViewTopConstraint.constant = padding / 2
      dotView.layer.borderColor = dotViewBorderColor.cgColor
      dotViewBottomConstraint.constant = 0
      backgroundView.layoutSubviews()
    }

  }

  private func setOff(animated: Bool = false) {
    if animated {
      isUserInteractionEnabled = false
      UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
          self.dotViewBottomConstraint.constant = self.padding * 2.5
          self.backgroundView.layoutSubviews()
        }
        UIView.addKeyframe(withRelativeStartTime:0.4, relativeDuration: 0.2) {
          self.dotView.layer.borderColor = self.dotViewBorderColor.cgColor
          self.backgroundView.layer.borderColor = self.backgroundViewBorderColor.cgColor
          self.backgroundView.layoutSubviews()
        }
        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
          self.dotViewTopConstraint.constant = self.padding * 3
          self.backgroundView.layoutSubviews()
        }
        self.isUserInteractionEnabled = true
      })
    } else {
      dotViewBottomConstraint.constant = padding * 2.5
      dotView.layer.borderColor = dotViewBorderColor.cgColor
      dotViewTopConstraint.constant = padding * 3
      backgroundView.layoutSubviews()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - actions
@objc
extension SwitchView {
  private func handleToggle() {
    isOn.toggle()
    setIsOn(isOn: isOn, animated: true, shouldPublish: true)
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
  }
}

// MARK: - public functions
extension SwitchView {
  public func setIsOn(isOn: Bool, animated: Bool = false, shouldPublish: Bool = false) {
    self.isOn = isOn
    isOn ? setOn(animated: animated) : setOff(animated: animated)
    if shouldPublish { isOnSubject.send(isOn) }
  }
}
