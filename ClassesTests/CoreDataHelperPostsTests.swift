/// File: CoreDataHelperPostsTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 17.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import XCTest
import FBPVClasses
import CoreData

class CoreDataHelperPostsTests : XCTestCase {
 
  override func tearDown() {
    super.tearDown()
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!
    var request = CoreDataHelper.Posts.sharedInstance.fetchRequestForAllRecordsSortedByCreatedDate
    var records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
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
    entity.desc = "Desc \(number)"
    entity.subtitle = "Subtitle \(number)"
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
    records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 3)
    XCTAssertTrue(records!.first! == p3)
    XCTAssertTrue(records![1] == p2)
    XCTAssertTrue(records!.last! == p1)
    
    
    // Records matching ID sorted by ID
    request = CoreDataHelper.Posts.sharedInstance.fetchRequestForRecordsMatchingIds(["ID 3", "ID 2", "ID X"])
    records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 2)
    XCTAssertTrue(records!.first! == p2)
    XCTAssertTrue(records!.last! == p3)

  }
  
  func testAddNewPosts() {
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
    
    let p4 = makeEntityWithNumber(4, type: "a")
    let p5 = makeEntityWithNumber(5, type: "a")
    CoreDataHelper.Posts.addOrUpdateRecordsWithEntities([p5, p4])
    request = CoreDataHelper.Posts.sharedInstance.fetchRequestForAllRecordsSortedByCreatedDate
    records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 5)
  }
  
  func testAddOrUpdatePosts() {
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
    
    let p4 = makeEntityWithNumber(4, type: "a")
    let p5 = makeEntityWithNumber(5, type: "a")
    p5.id = "ID 3"
    CoreDataHelper.Posts.addOrUpdateRecordsWithEntities([p5, p4])
    request = CoreDataHelper.Posts.sharedInstance.fetchRequestForAllRecordsSortedByCreatedDate
    records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 4)
    XCTAssertTrue(records!.first!.id == "ID 3")
  }

  func testPostsWithMissedPreviewImage() {
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!

    let p1 = makeEntityWithNumber(1, type: "a")
    let p2 = makeEntityWithNumber(2, type: "a")
    p1.pictureData = nil
    let p3 = makeEntityWithNumber(3, type: "a")
    let p4 = makeEntityWithNumber(3, type: "a")
    p4.pictureData = nil
    p4.pictureURL = nil

    moc.insertObject(p3)
    moc.insertObject(p1)
    moc.insertObject(p2)
    moc.insertObject(p4)

    CoreDataHelper.sharedInstance().saveContext()
    var request: NSFetchRequest
    var records: [PostEntity]?

    request = CoreDataHelper.Posts.sharedInstance.fetchRequestForRecordsWithoutPreviewImage
    records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 1)
    XCTAssertTrue(records!.first! == p1)

  }
  
  func testOldestPost() {
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
    
    request = CoreDataHelper.Posts.sharedInstance.fetchRequestForOldestPost
    records = CoreDataHelper.fetchRecordsAndLogError(request, PostEntity.self)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 1)
    XCTAssertTrue(records!.first!.id == "ID 1")

  }
}
