//
//  DeviceDetailsViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

import UIKit
import Moya

class DeviceDetailsViewController: UIViewController {
  private let colorPicker = UIColorPickerViewController()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: createLayout()
    )
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(cell: DeviceCollectionViewCell.self)
    collectionView.register(cell: DeviceModeCollectionViewCell.self)
    return collectionView
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
    title = device.name
    navigationItem.title = device.name
    view.backgroundColor = .white
    setupCollectionView()
  }

  private func setupCollectionView() {
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func createLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
//      switch section {
//      case 0:
//        return self.makeDeviceSectionLayout()
//      case 1:
        return self.makeDeviceModeSectionLayout()
//      default:
//        return nil
//      }
    }
  }

  private func makeDeviceSectionLayout() -> NSCollectionLayoutSection {
    let spacing: CGFloat = 8.0
    // item
    let itemSize: NSCollectionLayoutSize = .init(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(
      top: spacing,
      leading: spacing,
      bottom: spacing,
      trailing: spacing
    )
    // group
    let height = UIScreen.main.bounds.width * 0.5
    let groupSize: NSCollectionLayoutSize = .init(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(height))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    group.contentInsets = .init(
      top: .zero,
      leading: spacing,
      bottom: spacing,
      trailing: spacing
    )
    // section
    let section = NSCollectionLayoutSection(group: group)
    return section
  }

  private func makeDeviceModeSectionLayout() -> NSCollectionLayoutSection {
    let spacing: CGFloat = 8.0
    // item
    let itemSize: NSCollectionLayoutSize = .init(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(
      top: spacing,
      leading: spacing,
      bottom: spacing,
      trailing: spacing
    )
    // group
    let height = UIScreen.main.bounds.width * 0.25
    let groupSize: NSCollectionLayoutSize = .init(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(height))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    group.contentInsets = .init(
      top: .zero,
      leading: spacing,
      bottom: spacing,
      trailing: spacing
    )
    // section
    let section = NSCollectionLayoutSection(group: group)
    return section
  }

  @objc private func showPicker() {
    colorPicker.view.backgroundColor = .white
    navigationController?.pushViewController(colorPicker, animated: true)
  }
}

extension DeviceDetailsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    switch indexPath.section {
//    case 0:
//      break
//    case 1:
      switch indexPath.item {
      case 0:
        // color
        showPicker()
      case 1:
        // rainbow
        device.rainbow()
      case 2:
        // fire
        device.fire()
      case 3:
        // bitmap
        device.bitmap()
      case 4:
        // xmas
        device.xmas()
      default:
        break
      }
//    default:
//      break
//    }
  }

  private func makeModeCellsProps() -> [DeviceModeCollectionViewCell.Props] {
    return DeviceMode.allCases.map({.init(
      title: $0.title, color: .lightGray.withAlphaComponent(0.4)
    )})
  }
}

extension DeviceDetailsViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
//    2
    1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    switch section {
//    case 0:
//      return 1
//    case 1:
      return DeviceMode.allCases.count
//    default:
//      return 0
//    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    switch indexPath.section {
//    case 0:
//      let cell: DeviceCollectionViewCell = collectionView.dequeueReusableCell(forItemAt: indexPath)
//      return cell
//    case 1:
      let cell: DeviceModeCollectionViewCell = collectionView.dequeueReusableCell(forItemAt: indexPath)
      cell.render(props: makeModeCellsProps()[indexPath.item])
      return cell
//    default:
//      return UICollectionViewCell()
//    }
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
