//
//  ViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

struct Device: Hashable {
  let name: String
  let address: String
}

import UIKit

class ViewController: UIViewController {

  private let colorPicker = UIColorPickerViewController()

  private var devices: [Device] = []
  private var server: BonjourServer!

  private var selectedDevice: Device?

  private let tableView: UITableView = {
    let table = UITableView()
    return table
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .purple
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)

    view.addSubview(tableView)
    tableView.frame = view.frame
    tableView.reloadData()

    colorPicker.delegate = self

    server = BonjourServer()
    server.delegate = self

  }
}

extension ViewController: BonjourServerDelegate {
  func didResolveAddress(device: Device) {
    devices.append(device)
    tableView.reloadData()
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return devices.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let  cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else {
      return UITableViewCell()
    }

    cell.detailTextLabel?.text = devices[indexPath.row].name
    cell.textLabel?.text = devices[indexPath.row].name
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    selectedDevice = devices[indexPath.row]
    present(colorPicker, animated: true)
  }

  func sendRequest(address: String, color: String) {
    guard let url = URL(string: "http://" + address + "/color/") else {
      print("error occur while creating url")
      return
    }
    var request = URLRequest(url: url)
    request.httpBody = "color=\(color)".data(using: .utf8)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded",
                     forHTTPHeaderField: "Content-Type")
    let session = URLSession.shared

    session.dataTask(with: request) { data, response, error in
      if let data = data {
        let str = String(data: data, encoding: .utf8)
        print(str ?? "🥶", "Response")
      }
      if let error = error {
        print(error, "Eror")
      }
    }.resume()
  }
}

extension ViewController: UIColorPickerViewControllerDelegate {
  //  Called on every color selection done in the picker.
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    view.backgroundColor = viewController.selectedColor
    let color = hexStringFromColor(color: viewController.selectedColor)
    guard let device = selectedDevice else { return }
    sendRequest(address: device.address, color: color)
  }

  func hexStringFromColor(color: UIColor) -> String {
    let components = color.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    print(hexString)
    return hexString
  }
}

class TableViewCell: UITableViewCell {
  static let id = "deviceCell"
}
