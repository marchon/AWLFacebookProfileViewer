//
//  AppDelegate.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 21.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import CoreData
import FBPVUI
import FBPVClasses

let AppDelegateForceReloadChangeNotification = "AppDelegateForceReloadChangeNotification"

#if DEBUG
let AppDelegateDebugCommandNotification = "AppDelegateDebugCommandNotification"
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSNetServiceDelegate, NSStreamDelegate {

  var window: UIWindow?

  private var isUnderTestingMode: Bool {
    #if TEST
      return true
      #else
      return false
    #endif
  }

  private var rootViewController: UIViewController? {
    if self.isUnderTestingMode {
      let ctrl = UIViewController()
      ctrl.view.backgroundColor = UIColor.darkGrayColor()
      let label = UILabel(frame: ctrl.view.bounds)
      label.text = "Testing..."
      label.textAlignment = NSTextAlignment.Center
      label.font = UIFont.systemFontOfSize(28)
      label.textColor = UIColor.whiteColor()
      ctrl.view.addSubview(label)
      return ctrl
    } else {
      var storyBoardName = "Main"
      let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
      if let shouldSkipWelcomeScreen = AppState.UI.shouldSkipWelcomeScreen {
        if shouldSkipWelcomeScreen {
          return storyboard.instantiateInitialViewController() as? UIViewController
        }
      }
      let nc = storyboard.instantiateViewControllerWithIdentifier("welcomeScreenRootController") as? UINavigationController
      let ctrl = nc?.viewControllers.first as? WelcomeScreenViewController
      ctrl?.success = { (tokenInfo: (accessToken:String, expiresIn:Int)) -> () in
        AppState.UI.shouldSkipWelcomeScreen = true
        AppState.Authentication.facebookAccesToken = tokenInfo.accessToken
        AppState.Authentication.facebookAccesTokenExpitesIn = tokenInfo.expiresIn
        // Replacing root view controller on success.
        if let newRootViewController = storyboard.instantiateInitialViewController() as? UIViewController {
          self.window!.rootViewController = newRootViewController
          self.window!.makeKeyAndVisible()
          newRootViewController.view.alpha = 0.0
          UIView.animateWithDuration(0.5, animations: { () -> Void in
            newRootViewController.view.alpha = 1.0
          })
        }
      }
      return nc
    }
  }

  #if DEBUG
  private var server: NSNetService!
  private var inputStream: NSInputStream?
  private var outputStream: NSOutputStream?
  private var streamOpenCount = 0
  #endif

}

extension AppDelegate {

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {

    #if DEBUG
      if let envValue = NSProcessInfo.processInfo().environment["AWLEraseCustomDefaults"] as? String {
        if envValue == "YES" {
          logVerbose("Forced defaults cleanup")
          AppState.eraseCustomDefaults()
        }
      }
    #endif

    #if DEBUG
      logDebug("Main bundle URL: \(NSBundle.mainBundle().bundleURL)")
      logDebug("Documents directory URL: \(NSFileManager.applicationDocumentsDirectory)")
    #endif

    // UI
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.fromRGB(0xF9F9F9)
    self.window = window
    self.window!.rootViewController = self.rootViewController
    self.window!.makeKeyAndVisible()

    // Log fonts
    #if FAKEDEFINE
      for family in UIFont.familyNames() as! [String] {
      println(family)
      for name in UIFont.fontNamesForFamilyName(family) as! [String] {
      println("\t" + name)
      }
      }
    #endif

    #if DEBUG
      self.server = NSNetService(domain: "local.", type: "_wavelabs-debug._tcp.", name: UIDevice.currentDevice().name);
      self.server.includesPeerToPeer = true
      self.server.delegate = self
      self.server.publishWithOptions(NSNetServiceOptions.ListenForConnections)
    #endif

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    #if DEBUG
    self.server.stop()
    #endif
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    #if DEBUG
    self.server.publishWithOptions(NSNetServiceOptions.ListenForConnections)
    #endif
  }

  func applicationDidBecomeActive(application: UIApplication) {
    if let shouldReload = AppState.Settings.reloadAllDataWhenAppBecomeActive {
      if shouldReload {
        AppState.Settings.reloadAllDataWhenAppBecomeActive = false
        AppState.Posts.lastFetchDate = nil
        AppState.Friends.lastFetchDate = nil
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegateForceReloadChangeNotification, object: nil)
      }
    }
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    CoreDataHelper.sharedInstance().saveContext()
  }

}


#if DEBUG
extension AppDelegate {

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

extension AppDelegate {

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
            NSNotificationCenter.defaultCenter().postNotificationName(AppDelegateDebugCommandNotification, object: nil, userInfo: JSON as [NSObject : AnyObject])
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

