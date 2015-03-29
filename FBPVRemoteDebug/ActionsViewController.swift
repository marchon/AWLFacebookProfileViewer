//
//  ActionsViewController.swift
//  FBPVRemoteDebug
//
//  Created by Vlad Gorlov on 28.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Cocoa

protocol NetServiceDelegate {
  var connectionOpenHandler: (() -> ())?  { get set }
  var connectionCloseHandler: (() -> ())? { get set }
}

class ActionsView: NSView {

  /*
  @see https://github.com/foundry/NSViewControllerPresentation
  These click-blockers are required for the custom presented NSViewController's view, as it does not have it's own backing window.
  Without them, clicks are picked up by the buttons on the presentingViewControllers' view
  */
  override func mouseDown(theEvent: NSEvent) {
  }
  override func mouseDragged(theEvent: NSEvent) {
  }
  override func mouseUp(theEvent: NSEvent) {
  }

  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)

    // Background
    NSColor.controlColor().setFill()
    NSRectFill(self.bounds)
  }
}

class ActionsViewController: NSViewController, NSStreamDelegate, NetServiceDelegate {

  @IBOutlet weak var serviceNameLabel: NSTextField!
  @IBOutlet weak var commandComboBox: NSComboBox!
  private var inputStream: NSInputStream?
  private var outputStream: NSOutputStream?
  private var streamOpenCount = 0

  var connectionOpenHandler: (() -> ())?
  var connectionCloseHandler: (() -> ())?
}

extension ActionsViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    if let service = self.representedObject as? NSNetService {
      self.connectToService(service)
    }
  }

  override func dismissController(sender: AnyObject?) {
    super.dismissController(sender)
    self.disconnectFromService()
  }

}

extension ActionsViewController {

  @IBAction func sendAction(sender: NSControl) {
    if !self.commandComboBox.stringValue.isEmpty {
      self.sendMesage(["action": self.commandComboBox.stringValue])
    }
  }

  private func sendMesage(message: [String: String]) {
    if let stream = self.outputStream {
      var e: NSError?
      if let data = NSJSONSerialization.dataWithJSONObject(message, options: NSJSONWritingOptions.allZeros, error: &e) {
        stream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
      } else {
        println(e)
      }
    }
  }

  private func connectToService(service: NSNetService) {
    self.serviceNameLabel.stringValue = service.name

    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    let status = service.getInputStream(&inputStream, outputStream: &outputStream)
    assert(status)
    self.inputStream = inputStream
    self.outputStream = outputStream
    self.openStreams()

    self.connectionOpenHandler?()
  }

  private func disconnectFromService() {
    self.closeStreams()
    self.connectionCloseHandler?()
  }

  private func openStreams() {
    assert(self.inputStream != nil)
    assert(self.outputStream != nil)
    assert(self.streamOpenCount == 0)

    let openStream = {(stream: NSStream?) -> Void in
      stream?.delegate = self
      stream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
      stream?.open()
    }

    openStream(self.inputStream)
    openStream(self.outputStream)
  }

  private func closeStreams() {
    assert( (self.inputStream != nil) == (self.outputStream != nil) )      // should either have both or neither
    if self.inputStream != nil {
      let closeStream = {(stream: NSStream?) -> Void in
        stream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        stream?.close()
      }
      closeStream(self.inputStream)
      closeStream(self.outputStream)

      self.inputStream = nil
      self.outputStream = nil
    }
    self.streamOpenCount = 0
  }

}

extension ActionsViewController {
  func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    switch eventCode {
    case NSStreamEvent.OpenCompleted:
      self.streamOpenCount += 1

    case NSStreamEvent.HasSpaceAvailable:
      assert(aStream == self.outputStream)

    case NSStreamEvent.HasBytesAvailable:
      assert(aStream == self.inputStream)
      // Nothing to do for now

    case NSStreamEvent.ErrorOccurred:
      println(aStream.streamError)
      self.dismissController(self)
      
    case NSStreamEvent.EndEncountered:
      assert(true)
      
    default:
      assert(false)
    }
  }
}
