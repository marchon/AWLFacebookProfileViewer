//
//  MainViewController.swift
//  FBPVRemoteDebug
//
//  Created by Vlad Gorlov on 28.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSNetServiceBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate {

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  private var browser: NSNetServiceBrowser!
  private var services = [NSNetService]()
  private var selectedService: NSNetService?
  private var sortAndReloadTable: (() -> ())!
  private var applicationTerminationObserver: NSObjectProtocol?

}

extension MainViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.sortAndReloadTable = {
      self.services.sort { (lhs: NSNetService, rhs: NSNetService) -> Bool in
        return lhs.name < rhs.name
      }
      self.tableView.reloadData()
    }

    self.applicationTerminationObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSApplicationWillTerminateNotification,
      object: nil, queue: NSOperationQueue.mainQueue()) { (note: NSNotification!) -> Void in
        NSNotificationCenter.defaultCenter().removeObserver(self.applicationTerminationObserver!)
        self.stopSearch()
        self.browser.delegate = nil
        self.browser = nil
    }

    self.browser = NSNetServiceBrowser()
    self.browser.includesPeerToPeer = true
    self.browser.delegate = self
    self.startSearch()
  }



  override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
    let ctrl = segue.destinationController as! NSViewController
    ctrl.representedObject = self.selectedService
    var nedDelegate = segue.destinationController as! NetServiceDelegate
    nedDelegate.connectionOpenHandler = {
//      self.stopSearch()
    }
    nedDelegate.connectionCloseHandler = {
//      self.startSearch()
    }
  }
}


extension MainViewController {

  private func startSearch() {
    assert(self.services.count == 0)
    self.browser.searchForServicesOfType("_wavelabs-debug._tcp.", inDomain: "local")
  }

  private func stopSearch() {
    self.browser.stop()
    self.services.removeAll(keepCapacity: true)
    if self.viewLoaded {
      self.tableView.reloadData()
    }
  }
}

extension MainViewController {

  func tableViewSelectionDidChange(notification: NSNotification) {
    let selectedRow = self.tableView.selectedRow
    if selectedRow >= 0 && selectedRow < self.services.count {
      self.selectedService = self.services[selectedRow]
      self.performSegueWithIdentifier("connectToService", sender: self)
      self.tableView.deselectRow(selectedRow)
    }
  }

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return self.services.count
  }

  func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
    var service = self.services[row]
    if(tableColumn?.identifier == "name") {
      return service.name
    }
    return nil
  }

}

extension MainViewController {

  func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
    assert(aNetServiceBrowser == self.browser)
    println("[+] \(aNetService)")
    self.services.append(aNetService)
    if !moreComing {
      self.sortAndReloadTable()
    }
  }

  func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
    assert(aNetServiceBrowser == self.browser)
    println("[-] \(aNetService)")
    self.services = self.services.filter{ (service: NSNetService) -> Bool in
      return !service.isEqual(aNetService)
    }
    if !moreComing {
      self.sortAndReloadTable()
    }
    if (aNetService == self.selectedService) {
      if let ctrl = self.presentedViewControllers?.first as? NSViewController {
          self.dismissViewController(ctrl)
      }
    }
  }

  func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
    self.progressIndicator.startAnimation(self)
    println("Search started.")
  }

  func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
    self.progressIndicator.stopAnimation(self)
    println("Search stopped.")
  }

  func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
    println(errorDict)
    assert(false)
  }
}
