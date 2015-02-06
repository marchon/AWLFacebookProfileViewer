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
  lazy private var profileLoadManager: FacebookProfileLoadManager = {
    return FacebookProfileLoadManager()
    }()
  lazy private var friendsLoadManager: FacebookFriendsLoadManager = {
    return FacebookFriendsLoadManager()
    }()
  lazy private var postsLoadManager: FacebookPostsLoadManager = {
    return FacebookPostsLoadManager()
    }()
  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()
  
  var managedObjectContext: NSManagedObjectContext!
  
  //MARK: - Internal
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initChildControllers()
    
    if !AppState.UI.shouldShowWelcomeScreen {
      fetchProfileFromDatasource()
      fetchFriendsFromDatasource()
      fetchPostsFromDatasource()
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
        self.dismissViewControllerAnimated(true, completion: {
          () -> Void in
        })
      }
      ctrl.success = {
        (tokenInfo: (accessToken:String, expiresIn:Int)) -> () in
        var ps = PersistenceStore.sharedInstance()
        ps.facebookAccesToken = tokenInfo.accessToken
        ps.facebookAccesTokenExpitesIn = tokenInfo.expiresIn
        self.dismissViewControllerAnimated(true, completion: {
          () -> Void in
          self.fetchProfileFromDatasource()
          self.fetchFriendsFromDatasource()
          self.fetchPostsFromDatasource()
        })
      }
    }
  }
  
  //MARK: - Private
  
  private func updateProfileInformation(profile: Profile) {
    dispatch_async(dispatch_get_main_queue(), {
      self.topView.profileAvatar.image = profile.avatarPicture
      self.topView.userName.text = profile.userName
      self.topView.hometown.text = profile.hometown
      self.topView.coverPhoto.image = profile.coverPhoto
    })
  }
  
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
  
  private func updateFriendsTable(friends: [Friend]) {
    dispatch_async(dispatch_get_main_queue(), {
      self.friendsViewControoler.updateWithData(friends)
    })
  }
  
  private func updateFriendsTable(friendID: String, image: UIImage) {
    dispatch_async(dispatch_get_main_queue(), {
      self.friendsViewControoler.updateWithData(friendID, image: image)
    })
  }
  
}

//MARK: - Networking

extension MainViewController {
  private func fetchProfileFromServer() {
    profileLoadManager.fetchUserProfile({
      (results: FacebookProfileLoadManager.FetchResults) -> Void in
      let profile = Profile()
      profile.avatarPicture = results.avatarImage
      profile.userName = results.userProfileJson?.valueForKey("name") as? String
      profile.hometown = results.userProfileJson?.valueForKeyPath("hometown.name") as? String
      profile.coverPhoto = results.coverPhotoImage
      self.updateProfileInformation(profile)
      }, failure: {
        (error: NSError) -> Void in
        logError(self.removeSensitiveInformationFromError(error))
    })
  }
  
  private func fetchFriendsFromServer() {
    friendsLoadManager.fetchUserFriends({
      (results: FacebookFriendsLoadManager.FetchResults) -> Void in
      if let friends = results.friendsFeedChunks {
        var friendProfiles = [Friend]()
        for dict in friends {
          let friend = Friend()
          friend.userName = dict.valueForKey("name") as? String
          friend.id = dict.valueForKey("id") as? String
          let pictureUrlKey = "picture.data.url"
          if let URLString = dict.valueForKeyPath(pictureUrlKey) as? String {
            if let url = NSURL(string: URLString) {
              var imageDownLoadTask = self.backendManager.photoDownloadTask(url,
                success: {
                (image: UIImage) -> Void in
                  friend.avatarPicture = image
                  self.updateFriendsTable(friend.id!, image: image)
                },
                failure: {
                  (error: NSError) -> Void in
                  logError(self.removeSensitiveInformationFromError(error))
                }
              )
              imageDownLoadTask.resume()
            }
          }
          assert(friend.id != nil)
          friendProfiles.append(friend)
        }
        friendProfiles.sort({ (lhs: Friend, rhs: Friend) -> Bool in
          return lhs.userName < rhs.userName
        })
        self.updateFriendsTable(friendProfiles)
      }
      }, failure: {
        (error: NSError) -> Void in
        logError(self.removeSensitiveInformationFromError(error))
    })
  }
  
  private func fetchPostsFromServer() {
    postsLoadManager.fetchUserPosts({
      (results: FacebookPostsLoadManager.FetchResults) -> Void in
      if let postsDict = results.postsFeedChunks {
        var posts = [Post]()
        for dict in postsDict {
          if let postType = dict.valueForKey("type") as? String {
            if let type = Post.PostType(rawValue: postType) {
              let post = Post.postForType(type, properties: dict)
              if post.isValid {
                posts.append(post)
                
                if let URLString = post.pictureURLString {
                  if let url = NSURL(string: URLString) {
                    var imageDownLoadTask = self.backendManager.photoDownloadTask(url,
                      success: {
                        (image: UIImage) -> Void in
                        post.picture = image
                        self.updatePostsTable(post.id!, image: image)
                      },
                      failure: {
                        (error: NSError) -> Void in
                        logError(self.removeSensitiveInformationFromError(error))
                      }
                    )
                    imageDownLoadTask.resume()
                  }
                }
                
              } else {
                logWarn("Invalid post: \(post). Dictionary: \(dict)")
              }
            } else {
              logWarn("Unknown post type: \(postType). Dictionary: \(dict)")
            }
          }
        }
        self.updatePostsTable(posts)
      }
      }, failure: {
        (error: NSError) -> Void in
        logError(self.removeSensitiveInformationFromError(error))
    })
  }
  
  private func removeSensitiveInformationFromError(error: NSError) -> String {
    #if TEST || DEBUG
      return error.description
      #else
      if let token = PersistenceStore.sharedInstance().facebookAccesToken {
      return error.description.stringByReplacingOccurrencesOfString(token, withString: "TOKEN-WAS-STRIPPED")
      } else {
      return error.description
      }
    #endif
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
      if results.count == 0 {
        // Profile not yet fetched from server
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
  
  private func fetchFriendsFromDatasource() {
    #if DEBUG
      let dic = NSProcessInfo.processInfo().environment
      if dic["AWL_SKIP_DATASOURCE"] != nil {
        fetchFriendsFromServer()
        return
      }
    #endif
  }
  
  private func fetchPostsFromDatasource() {
    #if DEBUG
      let dic = NSProcessInfo.processInfo().environment
      if dic["AWL_SKIP_DATASOURCE"] != nil {
        fetchPostsFromServer()
        return
      }
    #endif
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
    
    postsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("postsViewControoler") as PostsTableViewController
    friendsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("friendsViewController") as FriendsTableViewController
    
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

