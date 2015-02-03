//
//  MainViewController.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 21.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import CoreData

import FacebookProfileViewerUI
import FacebookProfileViewerClasses

class MainViewController: UIViewController {
  
  @IBOutlet weak var topView: UserProfile!
  @IBOutlet weak var bottomView: UIView!
  
  private var postsViewControoler: UIViewController!
  private var friendsViewControoler: UIViewController!
  private var activeControllerType: ChildControllerType!
  lazy private var profileLoadManager: FacebookProfileLoadManager = {
    return FacebookProfileLoadManager()
    }()
  
  var managedObjectContext: NSManagedObjectContext!
  
  //MARK: - Internal
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initChildControllers()
    
    if !AppState.UI.shouldShowWelcomeScreen {
      fetchProfileFromDatasource()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutChildControllers()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if AppState.UI.shouldShowWelcomeScreen {
      AppState.UI.shouldShowWelcomeScreen = false
      performSegueWithIdentifier("showWelcomeScreen", sender: nil)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showWelcomeScreen" {
      let nc = segue.destinationViewController as UINavigationController
      let ctrl = nc.viewControllers.first as WelcomeScreenViewController
      ctrl.canceled = {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
      }
      ctrl.success = { (tokenInfo: (accessToken: String, expiresIn: Int)) -> () in
        var ps = PersistenceStore.sharedInstance()
        ps.facebookAccesToken = tokenInfo.accessToken
        ps.facebookAccesTokenExpitesIn = tokenInfo.expiresIn
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
          self.fetchProfileFromDatasource()
        })
      }
    }
  }
  
  //MARK: - Private
  
  private func updateProfileInformation(profile: Profile) {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.topView.profileAvatar.image = profile.avatarPicture
      self.topView.userName.text = profile.userName
      self.topView.hometown.text = profile.hometown
    })
  }
  
}

//MARK: - Networking

extension MainViewController {
  private func fetchProfileFromServer() {
    profileLoadManager.fetchUserProfile({ (results: FacebookProfileLoadManager.FetchResults) -> Void in
      let profile = Profile()
      profile.avatarPicture = results.avatarImage
      profile.userName = results.userProfileJson?.valueForKey("name") as? String
      profile.hometown = results.userProfileJson?.valueForKeyPath("hometown.name") as? String
      self.updateProfileInformation(profile)
      }, failure: { (error: NSError) -> Void in
      
    })
  }
  
  private func removeSensitiveInformationFromError(error: NSError) -> String {
    if let token = PersistenceStore.sharedInstance().facebookAccesToken {
      return error.description.stringByReplacingOccurrencesOfString(token, withString: "TOKEN-WAS-STRIPPED")
    } else {
      return error.description
    }
  }
}

//MARK: - Persistence

extension MainViewController {
  
  private func fetchProfileFromDatasource() {
    #if DEBUG
      let dic = NSProcessInfo.processInfo().environment
      if dic["AWL_SKIP_DATASOURCE"] != nil {
        fetchProfileFromServer()
        return
      }
    #endif
    
    let fetchRequest = NSFetchRequest()
    let entityName = ProfileEntity.description().componentsSeparatedByString(".").last!
    let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entityDescription
    
    var fetchError: NSError?
    var fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &fetchError)
    
    if let results = fetchResults {
      if results.count == 0 { // Profile not yet fetched from server
        fetchProfileFromServer()
      } else {
        var profileRecord = results.first as ProfileEntity
        let profile = Profile(entity: profileRecord)
        updateProfileInformation(profile)
      }
    } else {
      logError(fetchError!)
    }
  }
  
}

//MARK: - Child View Controllers

extension MainViewController {
  
  enum ChildControllerType : Int {
    case Posts
    case Friends
    func opposite () -> ChildControllerType {
      if self != .Posts {
        return .Posts
      } else {
        return .Friends
      }
    }
  }
  
  @IBAction func switchBottomView(sender: UISegmentedControl?) {
    let type = ChildControllerType(rawValue: sender?.selectedSegmentIndex ?? 0) ?? ChildControllerType.Posts
    switchToChildViewController(type)
  }
  
  //MARK: - Private
  
  private func initChildControllers() {
    
    activeControllerType = .Posts
    
    postsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("postsViewControoler") as UIViewController
    friendsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("friendsViewController") as UIViewController
    
    self.addChildViewController(postsViewControoler)
    self.addChildViewController(friendsViewControoler)
    
    let activeController = activeControllerType == .Posts ? postsViewControoler : friendsViewControoler
    self.bottomView.addSubview(activeController.view)
    
    postsViewControoler.didMoveToParentViewController(self)
    friendsViewControoler.didMoveToParentViewController(self)
  }
  
  private func layoutChildControllers() {
    for item in childViewControllers {
      (item as UIViewController).view.frame = bottomView.bounds
    }
  }
  
  private func switchToChildViewController(type: ChildControllerType) {
    if type == activeControllerType {
      return // Nothing to do
    }
    
    let from = type == .Posts ? friendsViewControoler : postsViewControoler
    let to = type == .Posts ? postsViewControoler : friendsViewControoler
    
    transitionFromViewController(from, toViewController: to, duration: 0.4, options: UIViewAnimationOptions.allZeros,
      animations: nil, completion: nil)
    activeControllerType = activeControllerType.opposite()
  }
  
}

