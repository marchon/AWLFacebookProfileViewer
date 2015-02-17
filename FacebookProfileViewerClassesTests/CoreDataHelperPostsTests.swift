/// File: CoreDataHelperPostsTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 17.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import XCTest
import FacebookProfileViewerClasses
import CoreData

class CoreDataHelperPostsTests : XCTestCase {
 
  override func tearDown() {
    super.tearDown()
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!
    var request = CoreDataHelper.Posts.sharedInstance.fetchRequestForAllRecordsSortedByCreatedDate
    var records = CoreDataHelper.Posts.fetchRecordsAndLogError(request)
    for result in records! {
      moc.deleteObject(result)
    }
    CoreDataHelper.sharedInstance().saveContext()
  }
  
  func makeEntityWithNumber(number: Int, type: String) -> PostEntity {
    let entity = CoreDataHelper.Posts.makeEntityInstance()
    entity.title = "Title \(number)"
    entity.type = type
    entity.id = "ID \(number)"
    entity.createdDate = NSDate(timeIntervalSinceReferenceDate: Double((number - 1) * 24 * 60 * 60))
    entity.pictureURL = "Picture URL \(number)"
    entity.pictureData = "Data \(number)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    entity.videoURL = "Video URL \(number)"
    return entity
  }
  
  func testReadonlyFetchRequests() {
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!

    let p1 = makeEntityWithNumber(1, type: "a")
    let p2 = makeEntityWithNumber(2, type: "a")
    let p3 = makeEntityWithNumber(3, type: "a")

    moc.insertObject(p3)
    moc.insertObject(p1)
    moc.insertObject(p2)
    
    CoreDataHelper.sharedInstance().saveContext()
    var request: NSFetchRequest
    var records: [PostEntity]?
    
    // All records sorted by created date
    request = CoreDataHelper.Posts.sharedInstance.fetchRequestForAllRecordsSortedByCreatedDate
    records = CoreDataHelper.Posts.fetchRecordsAndLogError(request)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 3)
    XCTAssertTrue(records!.first! == p1)
    XCTAssertTrue(records![1] == p2)
    XCTAssertTrue(records!.last! == p3)
    
  }
  
}
