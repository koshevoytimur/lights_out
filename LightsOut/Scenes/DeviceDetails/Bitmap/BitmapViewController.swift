//
//  BitmapViewController.swift
//  LightsOut
//
//  Created by Essence K on 21.12.2021.
//

import UIKit

struct BitmapVector {
  let colors: [[Int]]

  //  public var color: UIColor {
  //    guard colors.count == 3,
  //          let firstItem = colors.first,
  //          let color = UIColor(
  //            red: firstItem[0],
  //            green: <#T##CGFloat#>,
  //            blue: <#T##CGFloat#>,
  //            alpha: <#T##CGFloat#>
  //          )
  //    else { return UIColor.black }
  //
  //  }
}

class BitmapViewController: UIViewController {

  private let colorPicker = UIColorPickerViewController()
  
  private let tableView: UITableView = {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  private var vectors: [[Int]] = []

  private var selectedAmount: Int = 0
  private var selectedColor: UIColor = .black

  private let device: Device

  init(device: Device) {
    self.device = device

    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {
    setupView()
  }

  private func setupView() {
    view.backgroundColor = .systemBackground

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Add", style: .plain, target: self, action: #selector(addTapped)
    )

    colorPicker.delegate = self

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(DeviceCell.self, forCellReuseIdentifier: DeviceCell.id)
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    tableView.reloadData()

    let button = UIButton()
    button.backgroundColor = .red
    button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
    button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    view.addSubview(button)
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
      let textField = alert.textFields![0]
      print("Text field: \(textField.text)")
      self?.selectedAmount = Int(textField.text ?? "") ?? 0
      self?.showPicker()
    }))

    self.present(alert, animated: true, completion: nil)
  }

  private func appendArray(amount: Int, color: UIColor) {
    var vector: [[Int]] = []
    for _ in 0 ... amount {
      vector.append(colorToRGB(color))
    }
    self.vectors.append(contentsOf: vector)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

@objc
extension BitmapViewController {
  private func addTapped() {
    showAlert()
  }

  private func sendTapped() {
    device.bitmap(colors: vectors)
  }
}

extension BitmapViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //    guard let  cell = tableView.dequeueReusableCell(withIdentifier: DeviceCell.id) as? DeviceCell else {
    return UITableViewCell()
    //    }
    //    cell.detailTextLabel?.text = devices[indexPath.row].name
    //    cell.textLabel?.text = devices[indexPath.row].name
    //    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension BitmapViewController: UIColorPickerViewControllerDelegate {
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    print(colorToRGB(viewController.selectedColor))
    selectedColor = viewController.selectedColor
  }

  func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    appendArray(amount: selectedAmount, color: selectedColor)
  }

  func colorToRGB(_ color: UIColor) -> [Int] {
    var red = Int(color.rgba.red * color.rgba.alpha * 255)
    red = min(red, 255)
    red = max(red, 0)

    var blue = Int(color.rgba.blue * color.rgba.alpha * 255)
    blue = min(blue, 255)
    blue = max(blue, 0)

    var green = Int(color.rgba.green * color.rgba.alpha * 255)
    green = min(green, 255)
    green = max(green, 0)
    return [red, green, blue]
  }
}
