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

  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var topView: UserProfile!

  private var postsViewControoler: UIViewController!
  private var friendsViewControoler: UIViewController!
  private var activeControllerType: ChildControllerType!
  lazy private var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  var managedObjectContext: NSManagedObjectContext!

  //MARK: - Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    loadChildControllers()
    if !AppState.UI.shouldShowWelcomeScreen {
      fetchProfile()
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    for item in childViewControllers {
      (item as UIViewController).view.frame = bottomView.bounds
    }
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
        var ps = self.backendManager.persistenceStore
        ps.facebookAccesToken = tokenInfo.accessToken
        ps.facebookAccesTokenExpitesIn = tokenInfo.expiresIn
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
          self.fetchProfile()
        })
      }
    }
  }

  //MARK: - Private

  private func updateProfileInformation(profile: Profile) {

  }

}

//MARK: - Networking

extension MainViewController {
  private func fetchProfileFromServer() {
    var fetchTask = backendManager.fetchUserPictureURLDataTask({ [weak self] (url: String) -> Void in

      if let this = self {
        var downloadTask = this.backendManager.profilePictureImageDownloadTask(url,
          success: {(image: UIImage) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              this.topView.profileAvatar.image = image
            })
          },
          failure: {(error: NSError) -> Void in
            logError(this.removeSensisiveInformationFromError(error))
          }
        )
        downloadTask?.resume()
      }

      },
      failure: { [weak self] (error: NSError) -> Void in
        if let this = self {
          logError(this.removeSensisiveInformationFromError(error))
        }
      }
    )

    fetchTask?.resume()
  }

  private func removeSensisiveInformationFromError(error: NSError) -> String {
    if let token = backendManager.persistenceStore.facebookAccesToken {
      return error.description.stringByReplacingOccurrencesOfString(token, withString: "TOKEN-WAS-STRIPPED")
    } else {
      return error.description
    }
  }
}

//MARK: - Persistence

extension MainViewController {

  private func fetchProfile() {
    let fetchRequest = NSFetchRequest()
    let entityName = Profile.description().componentsSeparatedByString(".").last!
    let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entityDescription

    var fetchError: NSError?
    var fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &fetchError)

    if let results = fetchResults {
      if results.count == 0 { // Profile not yet fetched from server
        fetchProfileFromServer()
      } else {
        var profileRecord = results.first as Profile
        updateProfileInformation(profileRecord)
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

  private func loadChildControllers() {

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

