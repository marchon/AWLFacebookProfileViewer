/// File: ImageDownloadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class ImageDownloadManagerTests: EnpointTestCase {

  func testDownloadFriendsAvatars() {
    let mngr = FacebookFriendsLoadManager()
    mngr.fetchUserFriends({
      (results: FacebookFriendsLoadManager.FetchResults) -> Void in
      XCTAssertTrue(results.isResultsValid)

      var imageDownloadTasks = Array<ImageDownloadManager.FetchTask>()
      for dict in results.friendsFeedChunks! {
        var imageDownloadTask: ImageDownloadManager.FetchTask?
        if let URLString = dict.valueForKeyPath("picture.data.url") as? String {
          if let url = NSURL(string: URLString) {
            if let id = dict.valueForKeyPath("id") as? String {
              imageDownloadTask = ImageDownloadManager.FetchTask()
              imageDownloadTask?.downloadID = id
              imageDownloadTask?.downloadURL = url
            }
          }
        }
        if let task = imageDownloadTask {
          imageDownloadTasks.append(task)
        } else {
          XCTFail("Invalid download job. Dictionary: \(dict)")
        }
      }

      let dl = ImageDownloadManager()
      dl.downloadImages(imageDownloadTasks,
          success: {
            (results: [ImageDownloadManager.FetchResult]) -> Void in
            self.expectation.fulfill()
          },
          failure: {
            (error: NSError) -> Void in
            self.reportFailure(error)
          }
      )
    },
        failure: {
          (error: NSError) -> Void in
          self.reportFailure(error)
        })

    waitForExpectationsWithTimeout(45, handler: nil)
  }

}
