/// File: PersistenceStoreTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 10.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class PersistenceStoreTests : XCTestCase {
  func testSaveRestoreFetchChunksForPosts() {

    let now = NSDate()
    let chunk1 = FetchChunk()
    chunk1.startDate = NSDate(timeInterval: -2*24*60*60, sinceDate: now)
    chunk1.endDate = NSDate(timeInterval: -1*24*60*60, sinceDate: now)

    let chunk2 = FetchChunk()
    chunk2.startDate = NSDate(timeInterval: 1*24*60*60, sinceDate: now)
    chunk2.endDate = NSDate(timeInterval: 2*24*60*60, sinceDate: now)

    var chunks = [chunk1, chunk2]

    var ps = PersistenceStore.sharedInstance()
    ps.fetchChunksForPosts = chunks
    
    var restoredChunks = ps.fetchChunksForPosts
    XCTAssertTrue(restoredChunks?.count == 2)

  }
}
