//
//  RemoteDebugServer.swift
//  FBPV
//
//  Created by Vlad Gorlov on 29.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import UIKit.UIDevice

#if DEBUG

  class RemoteDebugServer: NSObject, NSNetServiceDelegate, NSStreamDelegate {

    static let ActionNotification = "RemoteDebugServerActionNotification"

    private var server: NSNetService!
    private var inputStream: NSInputStream?
    private var outputStream: NSOutputStream?
    private var streamOpenCount = 0

    override init() {
      super.init()
      self.server = NSNetService(domain: "local.", type: "_wavelabs-debug._tcp.", name: UIDevice.currentDevice().name);
      self.server.includesPeerToPeer = true
      self.server.delegate = self
    }

    func start() {
      self.server.publishWithOptions(NSNetServiceOptions.ListenForConnections)
    }

    func stop() {
      self.server.stop()
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

    func netServiceDidStop(sender: NSNetService) {
      println("Service stopped.")
      self.closeStreams()
    }

    func netServiceDidPublish(sender: NSNetService) {
      println("Service published.")
    }

    func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
      assert(sender == self.server)
      assert( (self.inputStream != nil) == (self.outputStream != nil) )      // should either have both or neither

      if self.inputStream != nil {
        // We already have a game in place; reject this new one.
        inputStream.open()
        inputStream.close()
        outputStream.open()
        outputStream.close()
      } else {
        //      self.server.stop()
        self.inputStream = inputStream
        self.outputStream = outputStream
        self.openStreams()
      }
    }

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
      switch eventCode {
      case NSStreamEvent.OpenCompleted:
        self.streamOpenCount += 1

      case NSStreamEvent.HasSpaceAvailable:
        assert(aStream == self.outputStream)

      case NSStreamEvent.HasBytesAvailable:
        assert(aStream == self.inputStream)

        if let stream = self.inputStream {
          var msg = NSMutableData()
          var buffer = Array<UInt8>(count: 512, repeatedValue: 0)
          while stream.hasBytesAvailable {
            let bytesRead = stream.read(&buffer, maxLength: buffer.count)
            if bytesRead <= 0 {
              // Do nothing; we'll handle EOF and error in the
              // NSStreamEventEndEncountered and NSStreamEventErrorOccurred case, respectively.
            } else {
              msg.appendBytes(buffer, length: bytesRead)
            }
          }
          if msg.length > 0 {
            var e: NSError?
            if let JSON = NSJSONSerialization.JSONObjectWithData(msg, options: NSJSONReadingOptions.allZeros, error: &e) as? NSDictionary {
              println(JSON)
              NSNotificationCenter.defaultCenter().postNotificationName(RemoteDebugServer.ActionNotification, object: nil, userInfo: JSON as [NSObject : AnyObject])
            } else {
              println(e)
            }
          }
        }

      case NSStreamEvent.ErrorOccurred:
        println(aStream.streamError)

      case NSStreamEvent.EndEncountered:
        self.closeStreams()
        self.server.publishWithOptions(NSNetServiceOptions.ListenForConnections)
        
      default:
        assert(false)
      }
    }

  }
  
#endif
