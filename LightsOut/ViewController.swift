//
//  ViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

struct Device {
  let name: String
  let address: String
}

import UIKit

class ViewController: UIViewController {

  let colorPicker = UIColorPickerViewController()

  let devices: [Device] = [
    Device(name: "desktop", address: "http://192.168.31.126"),
    Device(name: "tumba", address: "http://192.168.31.248")
  ]
    
  var server: BonjourServer!

  var selectedDevice: Device?

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
  func didChangeServices() {
      print("didChangeServices", server.devices)
  }

  func connected() {
      
  }
  
  func disconnected() {
      
  }
  
  func handleBody(_ body: NSString?) {
      
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
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
    selectedDevice = devices[indexPath.row]
    present(colorPicker, animated: true)
  }

  func sendRequest(address: String, color: String) {
    guard let url = URL(string: address + "/color/") else {
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
  func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    self.view.backgroundColor = viewController.selectedColor

  }

  //  Called on every color selection done in the picker.
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    self.view.backgroundColor = viewController.selectedColor
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

  func colorWithHexString(hexString: String) -> UIColor {
      var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
      colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()

      print(colorString)
      let alpha: CGFloat = 1.0
      let red: CGFloat = self.colorComponentFrom(colorString: colorString, start: 0, length: 2)
      let green: CGFloat = self.colorComponentFrom(colorString: colorString, start: 2, length: 2)
      let blue: CGFloat = self.colorComponentFrom(colorString: colorString, start: 4, length: 2)

      let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
      return color
  }

  func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {

      let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
      let endIndex = colorString.index(startIndex, offsetBy: length)
      let subString = colorString[startIndex..<endIndex]
      let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
      var hexComponent: UInt32 = 0

      guard Scanner(string: String(fullHexString)).scanHexInt32(&hexComponent) else {
          return 0
      }
      let hexFloat: CGFloat = CGFloat(hexComponent)
      let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
      print(floatValue)
      return floatValue
  }
}


class TableViewCell: UITableViewCell {
  static let id = "deviceCell"
}
