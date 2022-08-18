//
//  MainViewController.swift
//  LightsOut
//
//  Created by Essence K on 23.06.2021.
//

import UIKit
import Combine

class MainViewController: UIViewController {

  private let deviceService = DeviceService()
  private let theme: Theme = .dark

  private lazy var tableView: UITableView = {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    table.translatesAutoresizingMaskIntoConstraints = false
    table.register(MainTableViewCell.self)
    table.rowHeight = 200
    table.backgroundColor = theme.backgroundColor
    table.separatorStyle = .none
    table.delegate = self
    table.dataSource = self
    return table
  }()
  private let refreshControl = UIRefreshControl()

  private var cancellable = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {
    setupNavBar()
    setupView()
    setupBindings()
  }

  private func setupBindings() {
    deviceService.deviceFoundPublisher
      .debounce(for: 0.25, scheduler: DispatchQueue.main)
      .sink { [weak self] device in
        guard let self = self else { return }
        self.tableView.reloadData()
      }.store(in: &cancellable)
    deviceService.deviceUpdatePublisher
      .debounce(for: 0.25, scheduler: DispatchQueue.main)
      .sink { [weak self] device in
        guard let self = self,
              let index = self.deviceService.devices.firstIndex(where: { $0.name == device?.name })
        else { return }
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        self.tableView.endUpdates()
      }.store(in: &cancellable)
  }

  private func setupNavBar() {
    navigationController?.navigationBar.titleTextAttributes = [.font: theme.font18]
    title = "main"

    let mock = UIBarButtonItem(
      title: "mock", style: .plain, target: self, action: #selector(toogleMock)
    )
    mock.tintColor = theme.primaryColor
    mock.setTitleTextAttributes([.font: theme.font14], for: .normal)
    navigationItem.leftBarButtonItems = [mock]

    let blackout = UIBarButtonItem(
      title: "blackout", style: .plain, target: self, action: #selector(blackout)
    )
    blackout.tintColor = theme.primaryColor
    blackout.setTitleTextAttributes([.font: theme.font14], for: .normal)
    navigationItem.rightBarButtonItems = [blackout]
  }

  private func setupView() {
    setupTableView()
  }

  private func setupTableView() {
    view.backgroundColor = theme.backgroundColor
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    refreshControl.attributedTitle = NSAttributedString(string: "harder...", attributes: [.font: theme.font10])
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
  }

  private func handleSelectedMode(device: Device, mode: DeviceMode) {
    switch mode {
    case .color:
      break
    case .rainbow:
      deviceService.rainbow(device: device)
    case .fire:
      deviceService.fire(device: device)
    case .bitmap:
      break
    case .xmas:
      deviceService.xmas(device: device)
    default:
      break
    }
  }
}

// MARK: - actions
@objc
extension MainViewController {
  func refresh(_ sender: AnyObject) {
    deviceService.refresh()
    refreshControl.endRefreshing()
  }

  private func toogleMock() {
    deviceService.toggleMock()
  }

  private func blackout() {
    deviceService.turnOffAll()
  }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return deviceService.devices.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(forItemAt: indexPath, cellType: MainTableViewCell.self)
    guard indexPath.row < deviceService.devices.count else { fatalError("devices index out of bounds") }
    let device = deviceService.devices[indexPath.row]
    cell.update(device: device)

    cell.switchView.isOnPublisher.compactMap{ $0 }.sink { [weak self] _ in
      self?.deviceService.handleSwitchButtonPressed(device: device)
    }.store(in: &cell.cancellables)

    cell.emojiTextField.returnPublisher.compactMap{ $0 }.sink { [weak self] _ in
      self?.deviceService.saveEmoji(device: device, emoji: cell.emojiTextField.text ?? "🍉")
    }.store(in: &cell.cancellables)

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row < deviceService.devices.count else { return }
    let device = deviceService.devices[indexPath.row]
    let controller = ModeViewController(device: device, deviceService: deviceService)
    let modal = SemiModalViewController { controller }
    controller.modeSeleted.sink { [weak self] mode in
      self?.handleSelectedMode(device: device, mode: mode)
      self?.dismiss(animated: true)
    }.store(in: &cancellable)
    present(modal, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
}
