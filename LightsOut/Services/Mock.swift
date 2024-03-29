//
//  Mock.swift
//  LightsOut
//
//  Created by Essence K on 17.08.2022.
//

import Foundation

enum Mock {
  static var devices: [Device] = [
    Device(
      name: "office-table",
      address: "1321321312",
      info: .init(
        name: "office-table",
        numLeds: 228,
        mode: .fire,
        type: .ledStrip,
        settings: .init(
          color: "0000AA",
          speed: 1.0,
          brightness: 255,
          minBrightness: 50,
          maxBrightness: 255,
          msPerFrame: 255
        )
      )
    ),
    Device(
      name: "kitchen-lights",
      address: "1337",
      info: .init(
        name: "test",
        numLeds: 228,
        mode: .rainbow,
        type: .ledStrip,
        settings: .init(
          color: "00BB00",
          speed: 1.0,
          brightness: 255,
          minBrightness: 50,
          maxBrightness: 255,
          msPerFrame: 255
        )
      )
    )
  ]
}

//
//  BitmapViewController.swift
//  LightsOut
//
//  Created by Essence K on 21.12.2021.
//

// MARK: - Definitely need refactoring

import UIKit

struct BitmapVector: Codable {
  var colors: [[Int]]

  func color() -> UIColor? {
    return UIColor(
      red: CGFloat(colors.first?[0] ?? 1) / 255,
      green: CGFloat(colors.first?[1] ?? 1) / 255,
      blue: CGFloat(colors.first?[2] ?? 1) / 255,
      alpha: 1
    )
  }
}

class BitmapViewController: UIViewController {

  private let store = StoreService()

  private let reuseIdentifier = "BitmapCell"
  private let colorPicker = UIColorPickerViewController()

  private lazy var tableView: UITableView = {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    table.translatesAutoresizingMaskIntoConstraints = false
    table.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    return table
  }()

  private var items: [BitmapVector] = []

  private var selectedAmount: Int = 0
  private var selectedColor: UIColor = .black

  private var indexPathForEdit: IndexPath?

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
    colorPicker.delegate = self
    setupNavigationBar()
    setupView()
  }

  private func setupNavigationBar() {
    let send = UIBarButtonItem(
      title: "Send", style: .plain, target: self, action: #selector(send)
    )

    let add = UIBarButtonItem(
      title: "Add", style: .plain, target: self, action: #selector(add)
    )

    let load = UIBarButtonItem(
      title: "Load", style: .plain, target: self, action: #selector(load)
    )

    let save = UIBarButtonItem(
      title: "Save", style: .plain, target: self, action: #selector(save)
    )

    navigationItem.rightBarButtonItems = [send, add, load, save]
  }

  private func setupView() {
    view.backgroundColor = .systemBackground

    setupTableView()
  }

  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.dragDelegate = self
    tableView.dragInteractionEnabled = true
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  private func showPicker() {
    colorPicker.view.backgroundColor = .systemBackground
    present(colorPicker, animated: true)
  }

  private func showAlert() {
    let alert = UIAlertController(
      title: "Vector", message: "Enter lends amount", preferredStyle: .alert
    )

    alert.addTextField { (textField) in
      textField.placeholder = "amount"
      textField.keyboardType = .numberPad
    }

    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { [weak self] (_) in
      guard let self = self,
            let textField = alert.textFields?.first,
            let text = textField.text,
            !text.isEmpty,
            let amount = Int(text)
      else { return }
      self.selectedAmount = amount
      self.showPicker()
    }))

    self.present(alert, animated: true, completion: nil)
  }

  private func appendArray(amount: Int, color: UIColor) {
    var colors: [[Int]] = []
    for _ in 0 ..< amount {
      colors.append(color.toRGB())
    }
    let bitmapVector = BitmapVector(colors: colors)
    tableView.beginUpdates()
    guard let index = self.indexPathForEdit?.row else {
      self.items.append(bitmapVector)
      tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .fade)
      tableView.endUpdates()
      return
    }
    self.items.insert(bitmapVector, at: index)
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    tableView.endUpdates()
    indexPathForEdit = nil
  }

  private func makeBitmapRequest() -> BitmapRequest {
    var colors: [[Int]] = []
    for color in self.items {
      colors += color.colors
    }
    return BitmapRequest(colors: colors)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

@objc
extension BitmapViewController {
  private func add() {
    showAlert()
  }

  private func send() {
    deviceService.bitmap(device: device, makeBitmapRequest())
  }

  private func load() {
    guard let params = store.fetch([BitmapVector].self, key: "bitmap_request") else { return }
    items = params
    tableView.reloadData()
  }

  private func save() {
    store.save(items, key: "bitmap_request")
  }
}

extension BitmapViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    var content = cell.defaultContentConfiguration()

    content.text = "Count: \(items[indexPath.row].colors.count)"
    cell.backgroundColor = items[indexPath.row].color()
    cell.contentConfiguration = content

    return cell
  }

  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    let dragItem = UIDragItem(itemProvider: NSItemProvider())
    dragItem.localObject = items[indexPath.row]
    return [dragItem]
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let mover = items.remove(at: sourceIndexPath.row)
    items.insert(mover, at: destinationIndexPath.row)
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

    let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
      let item = self?.items[indexPath.row]
      self?.indexPathForEdit = indexPath
      self?.selectedAmount = item?.colors.count ?? 0
      self?.selectedColor = item?.color() ?? .black
      self?.items.remove(at: indexPath.row)
      self?.tableView.deleteRows(at: [indexPath], with: .automatic)
      self?.showAlert()
      completion(true)
    }

    return UISwipeActionsConfiguration(actions: [edit])
  }

  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete =  UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
      self?.items.remove(at: indexPath.row)
      self?.tableView.deleteRows(at: [indexPath], with: .automatic)
      completion(true)
    }

    let insert = UIContextualAction(style: .normal, title: "Insert") { [weak self] (_, _, completion) in
      self?.indexPathForEdit = IndexPath(row: indexPath.row + 1, section: indexPath.section)
      self?.showAlert()
      completion(true)
    }

    return UISwipeActionsConfiguration(actions: [delete, insert])
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension BitmapViewController: UIColorPickerViewControllerDelegate {
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    selectedColor = viewController.selectedColor
  }

  func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    appendArray(amount: selectedAmount, color: selectedColor)
  }
}






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
