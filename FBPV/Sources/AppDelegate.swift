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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  #if DEBUG
  var remoteDebugServer: RemoteDebugServer!
  var debugNotificationObserver: NSObjectProtocol?
  #endif

  private var isUnderTestingMode: Bool {
    #if TEST
      return true
      #else
      return false
    #endif
  }

  private var rootViewController: UIViewController? {
    if self.isUnderTestingMode {
      return UIViewController(nibName: "TestingView", bundle: NSBundle(forClass: AppDelegate.self))
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
}

extension AppDelegate {

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {

    logMarker("Starting application...")
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
      self.remoteDebugServer = RemoteDebugServer()
      self.remoteDebugServer.start()
      self.debugNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(RemoteDebugServer.ActionNotification,
        object: nil, queue: NSOperationQueue.mainQueue()) { (n: NSNotification!) -> Void in
          if let action = n.userInfo?["action"] as? String {
            self.handleDebugAction(action)
          }
      }
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
      self.remoteDebugServer.stop()
    #endif
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    #if DEBUG
      self.remoteDebugServer.start()
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


extension AppDelegate {
  #if DEBUG
  func handleDebugAction(action: String) {
    if action == "eraseCustomDefaults" {
      AppState.eraseCustomDefaults()
    }
  }
  #endif
}

