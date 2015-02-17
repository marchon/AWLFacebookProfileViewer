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

  private var postsViewControoler: PostsTableViewController!
  private var friendsViewControoler: FriendsTableViewController!
  private var activeControllerType: ChildControllerType!

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
    if AppState.UI.shouldShowWelcomeScreen {
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
          AppState.UI.shouldShowWelcomeScreen = false
        })
      }
      ctrl.success = {
        (tokenInfo: (accessToken:String, expiresIn:Int)) -> () in
        AppState.UI.shouldShowWelcomeScreen = false
        var ps = PersistenceStore.sharedInstance()
        ps.facebookAccesToken = tokenInfo.accessToken
        ps.facebookAccesTokenExpitesIn = tokenInfo.expiresIn
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

    if AppState.UI.shouldShowWelcomeScreen {
      return
    }

    var request = CoreDataHelper.Profile.sharedInstance.fetchRequestForProfile
    var fetchResults = CoreDataHelper.Profile.fetchRecordsAndLogError(request)
    if let results = fetchResults {
      if results.count == 0 {
        fetchProfileFromServer() // Profile not yet fetched from server
      } else {
        log.debug("Found \(results.count) profile record(s) in database")
        var profileRecord = results.first!
        updateProfileInformation(profileRecord)
      }
    }
  }

  private func fetchProfileFromServer() {
    profileLoadManager.fetchUserProfile(success: {
      (results: FacebookProfileLoadManager.FetchResults) -> Void in

      if let theUserName = results.userProfile.valueForKey("name") as? String {
        var entityInstance = CoreDataHelper.Profile.makeEntityInstance()
        entityInstance.userName = theUserName
        entityInstance.homeTown = results.userProfile.valueForKeyPath("hometown.name") as? String
        entityInstance.avatarPictureData = results.avatarPictureImageData
        entityInstance.coverPhotoData = results.coverPhotoImageData
        let moc = CoreDataHelper.sharedInstance().managedObjectContext!
        moc.performBlock({ () -> Void in
          moc.insertObject(entityInstance)
          CoreDataHelper.sharedInstance().saveContext()
        })
        self.updateProfileInformation(entityInstance)
      }
    }, failure: {
      (error: NSError) -> Void in
      logError(error.securedDescription)
    })
  }

  private func updateProfileInformation(profile: ProfileEntity) {
    dispatch_async(dispatch_get_main_queue(), {
      self.topView.userName.text = profile.userName
      self.topView.hometown.text = profile.homeTown
      if let theImageData = profile.avatarPictureData {
        self.topView.profileAvatar.image = UIImage(data: theImageData)
      }
      if let theImageData = profile.coverPhotoData {
        self.topView.coverPhoto.image = UIImage(data: theImageData)
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
  }

  @IBAction func switchBottomView(sender: UISegmentedControl?) {
    let type = ChildControllerType(rawValue: sender?.selectedSegmentIndex ?? 0) ?? ChildControllerType.Posts
    switchToChildViewController(type)
  }

  //MARK: - Private

  private func initChildControllers() {

    activeControllerType = .Posts

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
                                 animations: nil, completion: nil)
    activeControllerType = activeControllerType.opposite()
  }

}

