//
//  RainbowViewController.swift
//  LightsOut
//
//  Created by Essence K on 22.12.2021.
//

import UIKit
import Combine

class RainbowViewController: UIViewController {

  private let speedLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.text = "Speed"
    return label
  }()
  private let speedSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 0
    slider.maximumValue = 10
    slider.isContinuous = true
    return slider
  }()
  private let brightnessLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.text = "Brightness"
    return label
  }()
  private let brightnessSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 0
    slider.maximumValue = 255
    slider.isContinuous = true
    return slider
  }()

  private var selectedSpeed: Int = 0
  private var selectedBrightness: UIColor = .black

  private let device: Device
  private let deviceService: DeviceService

  init(device: Device, deviceService: DeviceService) {
    self.device = device
    self.deviceService = deviceService

    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {
    setupNavigationBar()
    setupView()
  }

  private func setupNavigationBar() {
    let send = UIBarButtonItem(
      title: "Send", style: .plain, target: self, action: #selector(send)
    )
//
//    let add = UIBarButtonItem(
//      title: "Add", style: .plain, target: self, action: #selector(add)
//    )
//
//    let load = UIBarButtonItem(
//      title: "Load", style: .plain, target: self, action: #selector(load)
//    )
//
//    let save = UIBarButtonItem(
//      title: "Save", style: .plain, target: self, action: #selector(save)
//    )
//
    navigationItem.rightBarButtonItems = [send]
  }

  private func setupView() {
    view.backgroundColor = .systemBackground

    setupSpeedLabel()
    setupSpeedSlider()
    setupBrightnessLabel()
    setupBrightnessSlider()
  }

  private func setupSpeedLabel() {
    view.addSubview(speedLabel, leading: 20, trailing: 20, top: 20)
  }

  private func setupSpeedSlider() {
    view.addSubview(speedSlider, constraints: [
      speedSlider.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 20),
      speedSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      speedSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }

  private func setupBrightnessLabel() {
    view.addSubview(brightnessLabel, constraints: [
      brightnessLabel.topAnchor.constraint(equalTo: speedSlider.bottomAnchor, constant: 20),
      brightnessLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      brightnessLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }

  private func setupBrightnessSlider() {
    view.addSubview(brightnessSlider, constraints: [
      brightnessSlider.topAnchor.constraint(equalTo: brightnessLabel.bottomAnchor, constant: 20),
      brightnessSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      brightnessSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

@objc
extension RainbowViewController {
  private func send() {
    deviceService.rainbow(
      device: device,
      .init(speed: Double(speedSlider.value), brightness: Int(brightnessSlider.value))
    )
  }

  private func save() {

  }
}
