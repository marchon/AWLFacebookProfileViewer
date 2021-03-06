/// File: MainViewController.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 21.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import CoreData

import FBPVUI
import FBPVClasses

class MainViewController: UIViewController, ErrorReportingProtocol {

  @IBOutlet weak var topView: UserProfileView!
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var bottomViewSwitcher: UISegmentedControl!

  private var errorDialog: OverlayErrorView?
  private var postsViewControoler: PostsTableViewController!
  private var friendsViewControoler: FriendsTableViewController!
  private var activeControllerType: ChildControllerType = ChildControllerType.Posts {
    didSet {
      self.bottomViewSwitcher.selectedSegmentIndex = self.activeControllerType.rawValue
    }
  }

  lazy private var profileLoadManager: FacebookProfileLoadManager = {
    return FacebookProfileLoadManager()
    }()

  //MARK: - Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    self.topView.loadProfileHandler = {
      self.fetchProfileFromDatasourceIfNeeded()
      self.friendsViewControoler.fetchUsersFromServerIfNeeded()
      self.postsViewControoler.fetchPostsFromServerIfNeeded()
      self.errorDialog?.dismiss()
    }
    self.topView.isProfileLoaded = false

    initChildControllers()
    fetchProfileFromDatasourceIfNeeded()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutChildControllers()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.fetchProfileFromDatasourceIfNeeded()
  }
}

//MARK: - Profile

extension MainViewController {

  private func fetchProfileFromDatasourceIfNeeded() {

    var shouldSkipWelcomeScreen = false
    if let theValue = AppState.UI.shouldSkipWelcomeScreen {
      shouldSkipWelcomeScreen = theValue
    }

    if !shouldSkipWelcomeScreen {
      return
    }

    var request = CoreDataHelper.Profile.sharedInstance.fetchRequestForProfile
    var fetchResults = CoreDataHelper.fetchRecordsAndLogError(request, ProfileEntity.self)
    if let results = fetchResults {
      if results.count == 0 {
        fetchProfileFromServer() // Profile not yet fetched from server
      } else {
        logDebugData("Found \(results.count) profile records in database.")
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
        if var fetchResults = CoreDataHelper.fetchRecordsAndLogError(request, ProfileEntity.self) {
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
        logErrorNetwork(error.securedDescription)
        self.showErrorDialog(error)
    })
  }

  private func updateProfileInformation(profile: ProfileEntity) {
    dispatch_async(dispatch_get_main_queue(), {
      self.topView.userName.text = profile.userName
      self.topView.hometown.text = profile.homeTown
      if let theImageData = profile.avatarPictureData {
        let theView = self.topView.profileAvatar
        theView.image = UIImage(data: theImageData)
      }
      if let theImageData = profile.coverPhotoData {
        self.topView.coverPhoto.image = UIImage(data: theImageData) // TODO: Adjust image parameters to achive better contrast with status bar
      }
      self.topView.isProfileLoaded = true
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

  func showErrorDialog(error: NSError) {
    dispatch_async(dispatch_get_main_queue(), {
      if self.errorDialog == nil{
        self.errorDialog = OverlayErrorView(error: error)
        self.errorDialog?.show(self.view, completion: {
          self.errorDialog = nil
        })
      }
    })
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
      (item as! UIViewController).view.frame = bottomView.bounds
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

