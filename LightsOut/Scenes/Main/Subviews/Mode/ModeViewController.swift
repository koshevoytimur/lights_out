//
//  ModeViewController.swift
//  LightsOut
//
//  Created by Essence K on 17.08.2022.
//

import UIKit
import Combine

class ModeViewController: UIViewController {

  public lazy var modeSeleted = modeSeletedSubject.eraseToAnyPublisher()
  private let modeSeletedSubject = PassthroughSubject<DeviceMode, Never>()

  private let padding: CGFloat = 8.0
  private let theme: Theme = .dark

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: makeLayout()
    )
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(cell: ModeCollectionViewCell.self)
    collectionView.backgroundColor = theme.primaryColor
    return collectionView
  }()

  private var modes: [DeviceMode] {
    DeviceMode.allCases.filter({ $0 != .disabled && $0 != .unknown })
  }

  private var cellSize: CGFloat {
    (UIScreen.main.bounds.width - padding * 2) / 6
  }

  private let device: Device
  private let deviceService: DeviceService

  init(device: Device, deviceService: DeviceService) {
    self.device = device
    self.deviceService = deviceService
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    view.backgroundColor = theme.primaryColor
    setupCollectionView()
  }

  private func setupCollectionView() {
    view.addSubview(
      collectionView,
      withSafeAreaEdgeInsets: .init(top: padding, left: padding, bottom: padding, right: padding)
    )
    collectionView.heightAnchor.constraint(equalToConstant: cellSize + padding).isActive = true
  }

  public func makeLayout() -> UICollectionViewLayout {
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.scrollDirection = .horizontal
    return UICollectionViewCompositionalLayout(
      sectionProvider: { section, environment in
        self.makeDeviceModeSectionLayout()
      },
      configuration: configuration
    )
  }

  private func makeDeviceModeSectionLayout() -> NSCollectionLayoutSection {
    // item
    let itemSize: NSCollectionLayoutSize = .init(
      widthDimension: .absolute(cellSize),
      heightDimension: .absolute(cellSize)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(
      top: padding,
      leading: padding,
      bottom: padding,
      trailing: padding
    )
    // group
    let height: CGFloat = cellSize
    let groupSize: NSCollectionLayoutSize = .init(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(height))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    group.contentInsets = .zero
    // section
    let section = NSCollectionLayoutSection(group: group)
    return section
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ModeViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return modes.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ModeCollectionViewCell = collectionView.dequeueReusableCell(forItemAt: indexPath)
    let mode = modes[indexPath.item]
    cell.update(mode: mode)
    let deviceMode = device.info?.mode ?? .unknown
    cell.setSelected(mode == deviceMode)
    return cell
  }
}

extension ModeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let mode = modes[indexPath.item]
    modeSeletedSubject.send(mode)
  }
}
