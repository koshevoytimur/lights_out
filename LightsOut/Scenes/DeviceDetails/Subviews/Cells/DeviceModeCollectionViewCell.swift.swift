//
//  DeviceModeCollectionViewCell.swift.swift
//  LightsOut
//
//  Created by Essence K on 20.12.2021.
//

import UIKit

class DeviceModeCollectionViewCell: UICollectionViewCell, ReusableCell {
  struct Props {
    let title: String
    let color: UIColor
  }

  private let padding: CGFloat = 8
  private let borderPadding: CGFloat = 4

  private lazy var mainStack = createStackView(color: .clear, axis: .horizontal)
  private lazy var buttonsStack = createStackView(color: .clear, axis: .horizontal)

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.layer.cornerRadius = 4
    label.clipsToBounds = true
    label.textColor = .black
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()
  private lazy var button: UIButton = {
    let button = UIButton()
    button.configuration = .tinted()
    button.configuration?.cornerStyle = .dynamic
    button.configuration?.baseBackgroundColor = .systemGreen
    button.configuration?.baseForegroundColor = .black
    button.configuration?.image = UIImage(systemName: "house.fill")
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    setupView()
  }

  private func setupView() {
    contentView.backgroundColor = .lightText
    contentView.layer.cornerRadius = 8
    setupContainerView()
    mainStack.addArrangedSubview(titleLabel)
    mainStack.addArrangedSubview(buttonsStack)
    buttonsStack.addArrangedSubview(UIView())
    buttonsStack.addArrangedSubview(button)
    button.widthAnchor.constraint(
      equalToConstant: UIScreen.main.bounds.width / 4
    ).isActive = true
  }

  private func setupContainerView() {
    mainStack.layer.cornerRadius = 8
    mainStack.frame = contentView.frame
    contentView.addSubview(mainStack)
  }

  public func render(props: Props) {
    titleLabel.text = props.title
    mainStack.backgroundColor = props.color
  }
}
