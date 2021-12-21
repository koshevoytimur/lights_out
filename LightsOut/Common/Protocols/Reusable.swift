import UIKit

protocol ReusableCell {
  static var reuseIdentifier: String { get }
}

extension ReusableCell {
  static var reuseIdentifier: String {
    String(describing: Self.self)
  }
}

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell & ReusableCell>(forItemAt indexPath: IndexPath, cellType: T.Type = T.self) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self).")
    }

    return cell
  }

  func register<T: UITableViewCell & ReusableCell>(_ cellType: T.Type) {
    register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
  }

  func register<T: UITableViewHeaderFooterView & ReusableCell>(_ headerFooter: T.Type) {
    register(headerFooter.self, forHeaderFooterViewReuseIdentifier: headerFooter.reuseIdentifier)
  }
}

extension UICollectionView {
  func dequeueReusableCell<Cell: ReusableCell>(withType type: Cell.Type = Cell.self, forItemAt indexPath: IndexPath) -> Cell {
    guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
      fatalError("Could not dequeue reusable cell with \(Cell.reuseIdentifier) reuse identifier.")
    }

    return cell
  }

  func dequeueReusableSupplementaryView<View: ReusableCell>(
    ofKind kind: String,
    withType type: View.Type = View.self,
    forItemAt indexPath: IndexPath
  ) -> View {
    let reusableView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: View.reuseIdentifier, for: indexPath)
    guard let view = reusableView as? View else {
      fatalError("Could not dequeue reusable view with \(View.reuseIdentifier) reuse identifier.")
    }

    return view
  }

  func register<C: UICollectionViewCell & ReusableCell>(cell: C.Type) {
    register(cell.self, forCellWithReuseIdentifier: C.reuseIdentifier)
  }

  func register<V: UICollectionReusableView & ReusableCell>(view: V.Type, ofKind kind: String) {
    register(view.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: V.reuseIdentifier)
  }
}
