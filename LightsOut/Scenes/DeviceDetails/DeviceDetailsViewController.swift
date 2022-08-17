//
//  DeviceDetailsViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

import UIKit
import Moya
import Combine

//
//  MARK: - this screen propably will be entirely removed
//

class DeviceDetailsViewController: UIViewController {
  private let viewModel = DeviceDetailsViewModel()

  private let colorPicker = UIColorPickerViewController()

  private let headerView = DeviceDetailsHeaderView()
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: viewModel.makeLayout()
    )
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(cell: DeviceCollectionViewCell.self)
    collectionView.register(cell: DeviceModeCollectionViewCell.self)
    return collectionView
  }()

  private lazy var colorSelectedPublisher = colorSelectedSubject.eraseToAnyPublisher()
  private let colorSelectedSubject = PassthroughSubject<UIColor, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private let device: Device
  private let deviceService: DeviceService

  init(device: Device, deviceService: DeviceService) {
    self.device = device
    self.deviceService = deviceService
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
    setupBindings()
  }

  private func setupBindings() {
    headerView.turnOnPublisher.sink { [weak self] _ in
      guard let self = self else { return }
    }.store(in: &cancellables)
    
    headerView.turnOffPublisher.sink { [weak self] _ in
      guard let self = self else { return }
    }.store(in: &cancellables)

    colorSelectedPublisher
      .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true)
      .sink { [weak self] color in
        guard let self = self else { return }
        self.deviceService.color(device: self.device, color: color.hexString())
      }.store(in: &cancellables)
  }

  private func setupView() {
    view.backgroundColor = .systemBackground
    setupHeaderView()
    setupCollectionView()
    guard let info = device.info else { return }
    let mode = info.settings?.color == "000000" ? "disabled" : info.mode.title
    self.headerView.render(props: .init(title: info.name, mode: mode, numLeds: info.numLeds))
  }

  private func setupHeaderView() {
    view.addSubview(headerView, leading: 16, trailing: 20, top: 16)
  }

  private func setupCollectionView() {
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func showPicker() {
    colorPicker.view.backgroundColor = .systemBackground
    if let color = device.info?.settings?.color {
      colorPicker.selectedColor = UIColor(hexRGB: color)
    }
    present(colorPicker, animated: true)
  }
}

extension DeviceDetailsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      switch indexPath.item {
      case 0:
        // color
        showPicker()
      case 1:
        // rainbow
        let vc = RainbowViewController(device: device, deviceService: deviceService)
        navigationController?.pushViewController(vc, animated: true)
      case 2:
        // fire
        deviceService.fire(device: device)
      case 3:
        // bitmap
        let vc = BitmapViewController(device: device, deviceService: deviceService)
        navigationController?.pushViewController(vc, animated: true)
      case 4:
        // xmas
        deviceService.xmas(device: device)
      default:
        break
      }
  }

  private func makeModeCellsProps() -> [DeviceModeCollectionViewCell.Props] {
    return DeviceMode.allCases.map({.init(title: $0.title)})
  }
}

extension DeviceDetailsViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return DeviceMode.allCases.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell: DeviceModeCollectionViewCell = collectionView.dequeueReusableCell(forItemAt: indexPath)
      cell.render(props: makeModeCellsProps()[indexPath.item])
      return cell
  }
}

extension DeviceDetailsViewController: UIColorPickerViewControllerDelegate {
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    colorSelectedSubject.send(viewController.selectedColor)
  }
}
