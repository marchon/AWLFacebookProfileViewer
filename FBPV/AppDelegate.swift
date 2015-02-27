//
//  AppDelegate.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 21.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import CoreData
import FBPVClasses

let AppDelegateForceReloadChangeNotification = "AppDelegateForceReloadChangeNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

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
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window!.rootViewController = self.rootViewController;
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

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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

  private var rootViewController: UIViewController? {
    var controller: UIViewController?
#if TEST
    let ctrl = UIViewController()
    ctrl.view.backgroundColor = UIColor.darkGrayColor()
    let label = UILabel(frame: ctrl.view.bounds)
    label.text = "Testing..."
    label.textAlignment = NSTextAlignment.Center
    label.font = UIFont.systemFontOfSize(28)
    label.textColor = UIColor.whiteColor()
    ctrl.view.addSubview(label)
    controller = ctrl
#else
    var storyBoardName = "Main"
    let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
    controller = storyboard.instantiateInitialViewController() as? UIViewController
#endif
    return controller
  }

}

