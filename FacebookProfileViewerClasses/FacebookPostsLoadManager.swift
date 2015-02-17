/// File: FacebookPostsLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class FacebookPostsLoadManager {

  private var posts = [NSDictionary]()
  private var fetchCursorNext: NSURL?

  private var fetchCallback: ([NSDictionary] -> Void)!
  private var successCallback: ([NSDictionary] -> Void)!
  private var failureCallback: (NSError -> Void)!

  private var since: NSDate?
  private var until: NSDate?
  private var numberOfElementsToFetch = 200

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  public init() {
  }

  public func fetchUserPosts(fetchCallback: (results:[NSDictionary]) -> Void, success: (results:[NSDictionary]) -> Void, failure: (error:NSError) -> Void) {
    self.fetchCallback = fetchCallback
    self.successCallback = success
    self.failureCallback = failure
    self.reset()
    self.performOperation()
  }

  public func fetchUserPosts(#since: NSDate?, until: NSDate?, maxPostsToFetch: Int, fetchCallback: (results:[NSDictionary]) -> Void, success: (results:[NSDictionary]) -> Void, failure: (error:NSError) -> Void) {
    self.fetchCallback = fetchCallback
    self.successCallback = success
    self.failureCallback = failure
    self.numberOfElementsToFetch = maxPostsToFetch
    self.since = since
    self.until = until
    self.reset()
    self.performOperation()
  }

  private func reset() {
    posts.removeAll(keepCapacity: true)
    fetchCursorNext = backendManager.fetchPostsURL(since: self.since, until: self.until)
  }

  private func performOperation() {
    if let url = self.fetchCursorNext {
      backendManager.fetchFacebookGraphAPITask(url,
        success:
        {
          (json: NSDictionary) -> Void in

          var isPostForRequestedDateFound = false
          let keyData = "data"
          if let dataArray = json.valueForKey(keyData) as? [NSDictionary] {
            var fetchedPosts = [NSDictionary]()
            if self.since != nil {
              let keyCreatedDate = "created_time"
              for item in dataArray {
                if let
                  createdDateString = item.valueForKey(keyCreatedDate) as? String {
                  if let createdDate = NSDateFormatter.facebookDateFormatter().dateFromString(createdDateString) {
                    // Post created later than requested date
                    if self.since!.compare(createdDate) == NSComparisonResult.OrderedAscending {
                      fetchedPosts.append(item)
                    }
                    else {
                      isPostForRequestedDateFound = true
                      break
                    }
                  }
                } else {
                  self.failureCallback(NSError.errorForMissedAttribute(keyCreatedDate))
                  return
                }
              }
            } else {
              fetchedPosts = dataArray
            }
            self.posts += fetchedPosts
            self.fetchCallback(fetchedPosts)
          } else {
            self.failureCallback(NSError.errorForMissedAttribute(keyData))
            return
          }

          if !isPostForRequestedDateFound && self.posts.count < self.numberOfElementsToFetch {
            let pagingKey = "paging.next"
            if let cursor = json.valueForKeyPath(pagingKey) as? String {
              self.fetchCursorNext = NSURL(string: cursor)
              self.performOperation()
            } else {
              self.successCallback(self.posts)
            }
          } else {
            self.successCallback(self.posts)
          }
        },
        failure: {
          (error: NSError) -> Void in
          self.failureCallback(error)
        }
        ).resume()
    }
  }
}
