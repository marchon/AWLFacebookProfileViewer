/// File: FacebookPostsLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class FacebookPostsLoadManager {

  public typealias SuccessCallback    = (([NSDictionary]) -> Void)
  public typealias FailureCallback    = ((NSError) -> Void)
  public typealias CompletionCallback = (() -> Void)

  private var cbCompletion: CompletionCallback!
  private var cbSuccess: SuccessCallback!
  private var cbFailure: FailureCallback!

  private var dateSince: NSDate?
  private var dateUntil: NSDate?
  private var numberOfElementsToFetch = 200
  private var numberOfElementsFetched = 0

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  public init() {
  }

  public func fetchUserPosts(#since: NSDate?, until: NSDate?, maxPostsToFetch: Int, success: SuccessCallback, failure: FailureCallback, completion: CompletionCallback) {
    self.cbCompletion = completion
    self.cbSuccess = success
    self.cbFailure = failure
    self.dateSince = since
    self.dateUntil = until
    self.numberOfElementsToFetch = maxPostsToFetch
    self.numberOfElementsFetched = 0
    if let url = backendManager.fetchPostsURL(since: self.dateSince, until: self.dateUntil) {
      self.performOperation(url)
    } else {
      cbFailure(NSError.errorForUninitializedURL())
    }
  }

  private func reset() {
    
  }

  private func performOperation(url: NSURL) {
      backendManager.fetchFacebookGraphAPITask(url,
        success:
        {
          (json: NSDictionary) -> Void in

          var isPostForRequestedDateFound = false
          let keyData = "data"
          if let dataArray = json.valueForKey(keyData) as? [NSDictionary] {
            var fetchedPosts = [NSDictionary]()
            if self.dateSince != nil {
              let keyCreatedDate = "created_time"
              for item in dataArray {
                if let
                  createdDateString = item.valueForKey(keyCreatedDate) as? String {
                  if let createdDate = NSDateFormatter.facebookDateFormatter().dateFromString(createdDateString) {
                    // Post created later than requested date
                    if self.dateSince!.compare(createdDate) == NSComparisonResult.OrderedAscending {
                      fetchedPosts.append(item)
                    }
                    else {
                      isPostForRequestedDateFound = true
                      break
                    }
                  }
                } else {
                  self.cbFailure(NSError.errorForMissedAttribute(keyCreatedDate))
                  return
                }
              }
            } else {
              fetchedPosts = dataArray
            }
            self.numberOfElementsFetched += fetchedPosts.count
            self.cbSuccess(fetchedPosts)
          } else {
            self.cbFailure(NSError.errorForMissedAttribute(keyData))
            return
          }

          if !isPostForRequestedDateFound && self.numberOfElementsFetched < self.numberOfElementsToFetch {
            let pagingKey = "paging.next"
            if let cursor = json.valueForKeyPath(pagingKey) as? String {
              if let fetchCursorNext = NSURL(string: cursor) {
                self.performOperation(fetchCursorNext)
              } else {
                self.cbFailure(NSError.errorForUninitializedURL())
              }
            } else {
              self.cbCompletion()
            }
          } else {
            self.cbCompletion()
          }
        },
        failure: {
          (error: NSError) -> Void in
          self.cbFailure(error)
        }
        ).resume()
  }
}
