//
//  DeviceCollectionViewCell.swift
//  LightsOut
//
//  Created by Essence K on 02.11.2021.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell, ReusableCell {
  private let padding: CGFloat = 8
  private let borderPadding: CGFloat = 4

  private lazy var mainStack = createStackView(color: .yellow, axis: .horizontal)
  private lazy var leftStack = createStackView(color: .systemPurple, axis: .vertical)
  private lazy var rightStack = createStackView(color: .yellow, axis: .vertical)
  private lazy var buttonsStack = createStackView(color: .yellow, axis: .horizontal)

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
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "house.fill"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .lightText
    imageView.layer.cornerRadius = 8
    return imageView
  }()

  private lazy var imageView1: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "camera.fill"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .lightText
    imageView.layer.cornerRadius = 4
    return imageView
  }()

  private lazy var label: UILabel = {
    let label = UILabel()
    label.layer.cornerRadius = 4
    label.clipsToBounds = true
    label.backgroundColor = .systemPink
    label.text = "init(coder:)"
    label.textColor = .black
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()
  private lazy var label1: UILabel = {
    let label = UILabel()
    label.layer.cornerRadius = 4
    label.clipsToBounds = true
    label.backgroundColor = .systemPink
    label.text = "init(coder:)"
    label.textColor = .black
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()
  private lazy var label2: UILabel = {
    let label = UILabel()
    label.layer.cornerRadius = 4
    label.clipsToBounds = true
    label.backgroundColor = .systemPink
    label.text = "init(coder:) has not been implemented"
    label.textColor = .black
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
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
    contentView.backgroundColor = .red
    contentView.layer.cornerRadius = 8
    setupContainerView()
    mainStack.addArrangedSubview(leftStack)
    mainStack.addArrangedSubview(rightStack)
    leftStack.addArrangedSubview(imageView)
    leftStack.addArrangedSubview(buttonsStack)
    buttonsStack.addArrangedSubview(turnOn)
    buttonsStack.addArrangedSubview(turnOff)
    rightStack.addArrangedSubview(.wrapView(imageView1, borderWidth: 4))
    rightStack.addArrangedSubview(.wrapView(label, borderWidth: 4))
    rightStack.addArrangedSubview(.wrapView(label1, borderWidth: 4))
    rightStack.addArrangedSubview(.wrapView(label2, borderWidth: 4))
  }

  private func setupContainerView() {
    mainStack.layer.cornerRadius = 8
    mainStack.frame = contentView.frame
    contentView.addSubview(mainStack)
  }
}

func createStackView(color: UIColor, axis: NSLayoutConstraint.Axis, padding: CGFloat = 8, margin: CGFloat = 8) -> UIStackView {
  let stack = UIStackView()
  stack.layer.cornerRadius = 8
  stack.backgroundColor = color
  stack.axis = axis
  stack.spacing = padding
  stack.distribution = .fillEqually
  stack.setMargins(margin)
  return stack
}
