//
//  DeviceDetailsViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

import UIKit

class DeviceDetailsViewController: UIViewController {
  private let colorPicker = UIColorPickerViewController()

  private let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .boldSystemFont(ofSize: 20)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()

  let device: Device

  init(device: Device) {
    self.device = device
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {
    colorPicker.delegate = self
    setupView()
  }

  private func setupView() {
    view.backgroundColor = .white
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
    view.addGestureRecognizer(tap)
    
    label.text = device.name + " " + device.address
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
      label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
      label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
    ])
  }

  @objc private func didTapLabel() {
    colorPicker.view.backgroundColor = .white
    navigationController?.pushViewController(colorPicker, animated: true)
  }
}

extension DeviceDetailsViewController: UIColorPickerViewControllerDelegate {
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    view.backgroundColor = viewController.selectedColor
    let color = hexStringFromColor(color: viewController.selectedColor)
    device.color(color: color)
  }

  private func hexStringFromColor(color: UIColor) -> String {
    let components = color.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    print(hexString)
    return hexString
  }
}
