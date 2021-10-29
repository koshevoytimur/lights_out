//
//  MainViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

import UIKit

class MainViewController: UIViewController {

  private var devices: [Device] = []
  private let server = BonjourServer()

  private let tableView: UITableView = {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {
    server.delegate = self
    setupView()
  }

  private func setupView() {
    title = "Main"
    navigationItem.largeTitleDisplayMode = .automatic
    view.backgroundColor = .white

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
  }
}

extension MainViewController: BonjourServerDelegate {
  func didResolveAddress(device: Device) {
    devices.append(device)
    tableView.reloadData()
  }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return devices.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let  cell = tableView.dequeueReusableCell(withIdentifier: DeviceCell.id) as? DeviceCell else {
      return UITableViewCell()
    }
    cell.detailTextLabel?.text = devices[indexPath.row].name
    cell.textLabel?.text = devices[indexPath.row].name
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let vc = UINavigationController(rootViewController: DeviceDetailsViewController(device: devices[indexPath.row]))
    showDetailViewController(vc, sender: self)
  }
}
