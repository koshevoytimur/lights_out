//
//  DeviceDetailsViewModel.swift
//  LightsOut
//
//  Created by Essence K on 21.12.2021.
//

import UIKit

final class DeviceDetailsViewModel {

  public func makeLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
        return self.makeDeviceModeSectionLayout()
    }
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
}
