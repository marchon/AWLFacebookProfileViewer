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
  @IBOutlet weak var bottomViewSwitcher: UISegmentedControl!

  private var postsViewControoler: PostsTableViewController!
  private var friendsViewControoler: FriendsTableViewController!
  private var activeControllerType: ChildControllerType = ChildControllerType.Posts {
    didSet {
      self.bottomViewSwitcher.selectedSegmentIndex = self.activeControllerType.rawValue
    }
  }

  lazy private var log: Logger = {
    return Logger.getLogger("M-VC")
  }()

  lazy private var profileLoadManager: FacebookProfileLoadManager = {
    return FacebookProfileLoadManager()
  }()

  //MARK: - Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    initChildControllers()
    fetchProfileFromDatasourceIfNeeded()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutChildControllers()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if let shouldSkipWelcomeScreen = AppState.UI.shouldSkipWelcomeScreen {
      if !shouldSkipWelcomeScreen {
        log.verbose("Will show welcome screen")
        performSegueWithIdentifier("showWelcomeScreen", sender: nil)
      }
    } else {
      log.verbose("Will show welcome screen")
      performSegueWithIdentifier("showWelcomeScreen", sender: nil)
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showWelcomeScreen" {
      let nc = segue.destinationViewController as UINavigationController
      let ctrl = nc.viewControllers.first as WelcomeScreenViewController
      ctrl.canceled = {
        self.dismissViewControllerAnimated(true, completion: {
          () -> Void in
          AppState.UI.shouldSkipWelcomeScreen = true
        })
      }
      ctrl.success = {
        (tokenInfo: (accessToken:String, expiresIn:Int)) -> () in
        AppState.UI.shouldSkipWelcomeScreen = true
        AppState.Authentication.facebookAccesToken = tokenInfo.accessToken
        AppState.Authentication.facebookAccesTokenExpitesIn = tokenInfo.expiresIn
        self.dismissViewControllerAnimated(true, completion: {
          () -> Void in
          self.fetchProfileFromDatasourceIfNeeded()
          self.friendsViewControoler.fetchUsersFromServerIfNeeded()
          self.postsViewControoler.fetchPostsFromServerIfNeeded()
        })
      }
    }
  }

}

//MARK: - Profile

extension MainViewController {

  private func fetchProfileFromDatasourceIfNeeded() {

    if let shouldSkipWelcomeScreen = AppState.UI.shouldSkipWelcomeScreen {
      if !shouldSkipWelcomeScreen {
        return
      }
    }

    #if DEBUG
      if let envValue = NSProcessInfo.processInfo().environment["AWLProfileAlwaysLoad"] as? String {
        if envValue == "YES" {
          fetchProfileFromServer()
          return
        }
      }
    #endif

    var request = CoreDataHelper.Profile.sharedInstance.fetchRequestForProfile
    var fetchResults = CoreDataHelper.Profile.fetchRecordsAndLogError(request)
    if let results = fetchResults {
      if results.count == 0 {
        fetchProfileFromServer() // Profile not yet fetched from server
      } else {
        log.debug("Found \(results.count) profile records in database.")
        var profileRecord = results.first!
        updateProfileInformation(profileRecord)
      }
    }
  }

  private func fetchProfileFromServer() {
    UIApplication.sharedApplication().showNetworkActivityIndicator()
    profileLoadManager.fetchUserProfile(success: { (results: FacebookProfileLoadManager.FetchResults) -> Void in

      UIApplication.sharedApplication().hideNetworkActivityIndicator()
      if let theUserName = results.userProfile.valueForKey("name") as? String {
        var request = CoreDataHelper.Profile.sharedInstance.fetchRequestForProfile
        var shouldInsert = true
        var entityInstance = CoreDataHelper.Profile.makeEntityInstance()
        if var fetchResults = CoreDataHelper.Profile.fetchRecordsAndLogError(request) {
          if fetchResults.count > 0 {
            entityInstance = fetchResults.first!
            shouldInsert = false
          }
        }
        entityInstance.userName = theUserName
        entityInstance.homeTown = results.userProfile.valueForKeyPath("hometown.name") as? String
        entityInstance.avatarPictureData = results.avatarPictureImageData
        entityInstance.coverPhotoData = results.coverPhotoImageData
        let moc = CoreDataHelper.sharedInstance().managedObjectContext!
        moc.performBlock({ () -> Void in
          if shouldInsert {
            moc.insertObject(entityInstance)
          }
          CoreDataHelper.sharedInstance().saveContext()
        })
        self.updateProfileInformation(entityInstance)
      }
    }, failure: { (error: NSError) -> Void in
      UIApplication.sharedApplication().hideNetworkActivityIndicator()
      logError(error.securedDescription)
    })
  }

  private func updateProfileInformation(profile: ProfileEntity) {
    dispatch_async(dispatch_get_main_queue(), {
      self.topView.userName.text = profile.userName
      self.topView.hometown.text = profile.homeTown
      if let theImageData = profile.avatarPictureData {
        let theView = self.topView.profileAvatar
        theView.image = UIImage(data: theImageData)
        theView.layer.borderWidth = 2
        theView.layer.borderColor = StyleKit.ProfileView.avatarBorderColor.CGColor
        let radius = 0.5 * max(CGRectGetHeight(theView.bounds), CGRectGetWidth(theView.bounds))
        theView.layer.cornerRadius = radius
        theView.clipsToBounds = true
      }
      if let theImageData = profile.coverPhotoData {
        self.topView.coverPhoto.image = UIImage(data: theImageData) // TODO: Adjust image parameters to achive better contrast with status bar
      }
    })
  }

}

//MARK: - Child View Controllers

extension MainViewController {

  enum ChildControllerType: Int {
    case Posts
    case Friends

    func opposite() -> ChildControllerType {
      if self != .Posts {
        return .Posts
      }
      else {
        return .Friends
      }
    }

    var stringValue: String {
      switch self {
        case .Posts:
          return "posts"
        case .Friends:
          return "friends"
      }
    }

    static func fromString(type: String) -> ChildControllerType {
      if type == ChildControllerType.Friends.stringValue {
        return ChildControllerType.Friends
      } else {
        return ChildControllerType.Posts
      }
    }
  }

  @IBAction func switchBottomView(sender: UISegmentedControl?) {
    let type = ChildControllerType(rawValue: sender?.selectedSegmentIndex ?? 0) ?? ChildControllerType.Posts
    self.switchToChildViewController(type)
  }

  //MARK: - Private

  private func initChildControllers() {

    if let type = AppState.UI.bottomControllerType {
      self.activeControllerType = ChildControllerType.fromString(type)
    }

    postsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("postsViewControoler") as? PostsTableViewController
    friendsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("friendsViewController") as? FriendsTableViewController

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
                                 animations: nil, completion: { (finished:Bool) -> Void in
      if finished {
        self.activeControllerType = self.activeControllerType.opposite()
        AppState.UI.bottomControllerType = self.activeControllerType.stringValue
      }
    })
  }

}

