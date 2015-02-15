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

  lazy private var postsLoadManager: FacebookPostsLoadManager = {
    return FacebookPostsLoadManager()
  }()
  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
  }()

  var managedObjectContext: NSManagedObjectContext {
    return CoreDataHelper.sharedInstance().managedObjectContext!
  }

  //MARK: - Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    initChildControllers()

    fetchProfileFromDatasource()

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
          self.fetchProfileFromDatasource()
          self.friendsViewControoler.loadUsersFromServerIfNeeded()
        })
      }
    }
  }

  //MARK: - Private

  private func updatePostsTable(posts: [Post]) {
    dispatch_async(dispatch_get_main_queue(), {
      self.postsViewControoler.updateWithData(posts)
    })
  }

  private func updatePostsTable(postID: String, image: UIImage) {
    dispatch_async(dispatch_get_main_queue(), {
      self.postsViewControoler.updateWithData(postID, image: image)
    })
  }

}

//MARK: - Networking

extension MainViewController {

  private func processFetchedPosts(results: [NSDictionary]) {
    var posts = [Post]()
    for dict in results {
      if let post = Post(properties: dict) {
        if let URLString = post.pictureURLString {
          if let url = NSURL(string: URLString) {
            let imageDownLoadTask = self.backendManager.photoDownloadTask(
            url,
            success: {
              (image: UIImage) -> Void in
              post.picture = image
              self.updatePostsTable(post.id, image: image)
            },
            failure: {
              (error: NSError) -> Void in
              logError(self.removeSensitiveInformationFromError(error))
            })
            imageDownLoadTask.resume()
          }
        }
        posts.append(post)
      }
      else {
        logWarn("Invalid post dictionary: \(dict)")
      }
    }
    self.updatePostsTable(posts)
  }

  private func fetchPostsFromServer() {
    postsLoadManager.fetchUserPosts(since: nil, until: nil, maxPostsToFetch: 200,
                                    fetchCallback: {
                                      (results: [NSDictionary]) -> Void in
                                      self.processFetchedPosts(results)
                                    },
                                    success: {
                                      (results: [NSDictionary]) -> Void in
                                    },
                                    failure: {
                                      (error: NSError) -> Void in
                                      logError(self.removeSensitiveInformationFromError(error))
                                    }
    )
  }

  private func removeSensitiveInformationFromError(error: NSError) -> String {
    return error.securedDescription
  }
}

//MARK: - Profile

extension MainViewController {

  private func fetchProfileFromDatasource() {

    if AppState.UI.shouldShowWelcomeScreen {
      return
    }

    let fetchRequest = NSFetchRequest()
    let entityName = ProfileEntity.description().componentsSeparatedByString(".").last!
    let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entityDescription

    var fetchError: NSError?
    var fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &fetchError)

    if let results = fetchResults {
      if results.count == 0 {
        // Profile not yet fetched from server
        fetchProfileFromServer()
      }
      else {
        log.debug("Found \(results.count) profile record(s) in database")
        var profileRecord = results.first as ProfileEntity
        updateProfileInformation(profileRecord)
      }

    }
    else {
      log.error(fetchError!)
    }
  }

  private func fetchProfileFromServer() {
    profileLoadManager.fetchUserProfile(success: {
      (results: FacebookProfileLoadManager.FetchResults) -> Void in

      if let theUserName = results.userProfile.valueForKey("name") as? String {
        let entityName = ProfileEntity.description().componentsSeparatedByString(".").last!
        let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
        var entityInstance = ProfileEntity(entity: entityDescription!, insertIntoManagedObjectContext: self.managedObjectContext)
        entityInstance.userName = theUserName
        entityInstance.homeTown = results.userProfile.valueForKeyPath("hometown.name") as? String
        entityInstance.avatarPictureData = results.avatarPictureImageData
        entityInstance.coverPhotoData = results.coverPhotoImageData
        CoreDataHelper.sharedInstance().saveContext()
        self.updateProfileInformation(entityInstance)
      }
    }, failure: {
      (error: NSError) -> Void in
      logError(self.removeSensitiveInformationFromError(error))
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

