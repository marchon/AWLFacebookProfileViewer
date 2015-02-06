/// File: FacebookPostsLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class FacebookPostsLoadManager {

  private var postsFeedChunks = [NSDictionary]()
  var lastOperationError: NSError?
  var fetchCursorNext: NSURL?

#if TEST
  let maxNumberOfTotalPostsToFetch = 60
#else
  let maxNumberOfTotalPostsToFetch = 200
#endif

  var fetchCallback: ([NSDictionary] -> Void)!
  var successCallback: ([NSDictionary] -> Void)!
  var failureCallback: (NSError -> Void)!

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

  private func reset() {
    postsFeedChunks.removeAll(keepCapacity: true)
    fetchCursorNext = backendManager.fetchPostsURL()
  }

  private func performOperation() {
    if let url = self.fetchCursorNext {
      backendManager.fetchFacebookGraphAPITask(url,
          success:
          {
            (json: NSDictionary) -> Void in

            let dataKey = "data"
            if let dataArray = json.valueForKey(dataKey) as? Array<NSDictionary> {
              self.postsFeedChunks += dataArray
              self.fetchCallback(dataArray)
            } else {
              self.failureCallback(NSError.errorForMissedAttribute(dataKey))
              return
            }

            if self.postsFeedChunks.count < self.maxNumberOfTotalPostsToFetch {
              let pagingKey = "paging.next"
              if let nextCursor = json.valueForKeyPath(pagingKey) as? String {
                self.fetchCursorNext = NSURL(string: nextCursor)
                self.performOperation()
              } else {
                self.successCallback(self.postsFeedChunks)
              }
            } else {
              self.successCallback(self.postsFeedChunks)
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
