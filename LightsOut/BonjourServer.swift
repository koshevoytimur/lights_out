//
//  BonjourServer.swift
//  bonjour-demo-mac
//
//  Created by James Zaghini on 14/05/2015.
//  Copyright (c) 2015 James Zaghini. All rights reserved.
//
import Foundation

enum PacketTag: Int {
  case header = 1
  case body = 2
}

protocol BonjourServerDelegate: AnyObject {
  func connected()
  func disconnected()
  func handleBody(_ body: NSString?)
  func didChangeServices()
  func didResolveAddress(device: Device)
}

extension BonjourServerDelegate {
  func connected() {}
  func disconnected() {}
  func handleBody(_ body: NSString?) {}
  func didChangeServices() {}
  func didResolveAddress(device: Device) {}
}

class BonjourServer: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, GCDAsyncSocketDelegate {
  
  weak var delegate: BonjourServerDelegate?
  
  private var coServiceBrowser: NetServiceBrowser!
  
  private var devices: Array<NetService>!
  
  private var connectedService: NetService!
  
  private var sockets: [String : GCDAsyncSocket]!
  
  override init() {
    super.init()
    devices = []
    sockets = [:]
    startService()
  }
  
  func parseHeader(_ data: Data) -> UInt {
    var out: UInt = 0
    (data as NSData).getBytes(&out, length: MemoryLayout<UInt>.size)
    return out
  }
  
  func handleResponseBody(_ data: Data) {
    if let message = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
      self.delegate?.handleBody(message)
    }
  }
  
  func connectTo(_ service: NetService) {
    service.delegate = self
    service.resolve(withTimeout: 15)
  }
  
  // MARK: NSNetServiceBrowser helpers
  
  func stopBrowsing() {
    if coServiceBrowser != nil {
      coServiceBrowser.stop()
      coServiceBrowser.delegate = nil
      coServiceBrowser = nil
    }
  }
  
  func startService() {
    if devices != nil {
      devices.removeAll(keepingCapacity: true)
    }
    
    coServiceBrowser = NetServiceBrowser()
    coServiceBrowser.delegate = self
    coServiceBrowser.searchForServices(ofType: "_http._tcp", inDomain: "local.")
  }
  
  func send(_ data: Data) {
    print("send data")
    
    if let socket = getSelectedSocket() {
      var header = data.count
      let headerData = Data(bytes: &header, count: MemoryLayout<UInt>.size)
      socket.write(headerData, withTimeout: -1.0, tag: PacketTag.header.rawValue)
      socket.write(data, withTimeout: -1.0, tag: PacketTag.body.rawValue)
    }
  }
  
  func connectToServer(_ service: NetService) -> Bool {
    var connected = false
    
    let addresses: Array = service.addresses!
    var socket = self.sockets[service.name]
    
    if !(socket?.isConnected != nil) {
      socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
      
      while !connected && !addresses.isEmpty {
        let address: Data = addresses[0]
        do {
          guard let socket = socket else { return true }
          try socket.connect(toAddress: address)
          sockets.updateValue(socket, forKey: service.name)
          connectedService = service
          connected = true
        } catch {
          print(error)
        }
      }
    }
    return true
  }
  
  // MARK: NSNetService Delegates
  
  func netServiceDidResolveAddress(_ sender: NetService) {
    var address: String = ""
    if let addresses = sender.addresses, !addresses.isEmpty {
      address = String(decoding: addresses[0], as: UTF8.self)
      print("did resolve address \(sender.name)", sender.addresses?.count ?? 0, address)
    }
    var hostname = [CChar] (repeating: 0, count: Int (NI_MAXHOST))
    guard let data = sender.addresses?.first else {return}
    do {
      try data.withUnsafeBytes { (pointer: UnsafePointer<sockaddr>) in
        guard getnameinfo (pointer, socklen_t (data.count),&hostname, socklen_t (hostname.count), nil, 0, NI_NUMERICHOST) == 0
        else { throw NSError (domain: "error_domain", code: 0, userInfo: .none) }
        let address = String (cString: hostname)
        let device = Device(name: sender.name, address: address, leds: [Device.Led]())
        delegate?.didResolveAddress(device: device)
      }
    } catch {
      print (error)
    }
  }
  
  func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
    print("net service did no resolve. errorDict: \(errorDict)")
  }
  
  // MARK: GCDAsyncSocket Delegates
  
  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    print("connected to host \(String(describing: host)), on port \(port)")
    sock.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: 0)
  }
  
  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    print("socket did disconnect \(String(describing: sock)), error: \(String(describing: err?._userInfo))")
  }
  
  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    print("socket did read data. tag: \(tag)")
    guard sock == getSelectedSocket() else { return }
    if data.count == MemoryLayout<UInt>.size {
      let bodyLength: UInt = parseHeader(data)
      sock.readData(toLength: bodyLength, withTimeout: -1, tag: PacketTag.body.rawValue)
    } else {
      handleResponseBody(data)
      sock.readData(toLength: UInt(MemoryLayout<UInt>.size), withTimeout: -1, tag: PacketTag.header.rawValue)
    }
  }
  
  func socketDidCloseReadStream(_ sock: GCDAsyncSocket) {
    print("socket did close read stream")
  }
  
  // MARK: NSNetServiceBrowser Delegates
  
  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
    self.devices.append(aNetService)
    aNetService.delegate = self
    aNetService.resolve (withTimeout: 5.0)
    if !moreComing {
      delegate?.didChangeServices()
    }
  }
  
  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
    guard let index = devices.firstIndex(of: aNetService) else { return }
    devices.remove(at: index)
    
    if !moreComing {
      delegate?.didChangeServices()
    }
  }
  
  func netServiceBrowserDidStopSearch(_ aNetServiceBrowser: NetServiceBrowser) {
    stopBrowsing()
  }
  
  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    stopBrowsing()
  }
  
  // MARK: helpers
  
  func getSelectedSocket() -> GCDAsyncSocket? {
    sockets[connectedService.name]
  }
}
