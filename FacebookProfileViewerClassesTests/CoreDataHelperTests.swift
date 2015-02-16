/// File: CoreDataHelperTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 16.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import XCTest
import FacebookProfileViewerClasses
import CoreData

class CoreDataHelperTests : XCTestCase {
  
  func makeEntityWithNumber(number: Int) -> FriendEntity {
    let entity = CoreDataHelper.Friends.makeEntityInstance()
    entity.userName = "User \(number)"
    entity.avatarPictureURL = "Picture URL \(number)"
    return entity
  }
  
  func testReadonlyFetchRequests () {
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!
    
    let f1 = makeEntityWithNumber(1)
    f1.avatarPictureData = "Data 1".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    let f2 = makeEntityWithNumber(2)
    let f3 = makeEntityWithNumber(3)
    f3.avatarPictureData = "Data 3".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

    // Non althabetical order
    moc.insertObject(f3)
    moc.insertObject(f1)
    moc.insertObject(f2)

    CoreDataHelper.sharedInstance().saveContext()
    var request: NSFetchRequest
    var records: [FriendEntity]?
    
    // All records sorted by name
    request = CoreDataHelper.Friends.sharedInstance.fetchRequestForAllRecordsSortedByName
    records = CoreDataHelper.Friends.fetchRecordsAndLogError(request)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 3)
    XCTAssertTrue(records!.first! == f1)
    XCTAssertTrue(records![1] == f2)
    XCTAssertTrue(records!.last! == f3)
    
    // Records with missed avatar
    request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsWithoutAvatarImage
    records = CoreDataHelper.Friends.fetchRecordsAndLogError(request)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 1)
    XCTAssertTrue(records!.first! == f2)
    
    // Records for requested names
    request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsMatchingNames(["User 1", "User 2", "User X"])
    records = CoreDataHelper.Friends.fetchRecordsAndLogError(request)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 2)
    XCTAssertTrue(records!.first! == f1)
    XCTAssertTrue(records!.last! == f2)
    
    // Records not matching requested names
    request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsNotMatchingNames(["User 1", "User 2", "User X"])
    records = CoreDataHelper.Friends.fetchRecordsAndLogError(request)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 1)
    XCTAssertTrue(records!.first! == f3)
  }
  
  func testDeleteNotMatchedEntities() {
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!
    
    let f1 = makeEntityWithNumber(1)
    let f2 = makeEntityWithNumber(2)
    let f3 = makeEntityWithNumber(3)
    moc.insertObject(f1)
    moc.insertObject(f3)
    moc.insertObject(f2)
    
    CoreDataHelper.sharedInstance().saveContext()
    var request: NSFetchRequest
    var records: [FriendEntity]?
    
    CoreDataHelper.Friends.deleteRecordsNotMatchingNames(["User 3", "User X"])
    
    // All records sorted by name
    request = CoreDataHelper.Friends.sharedInstance.fetchRequestForAllRecordsSortedByName
    records = CoreDataHelper.Friends.fetchRecordsAndLogError(request)
    XCTAssertNotNil(records)
    XCTAssertTrue(records!.count == 1)
    XCTAssertTrue(records!.first! == f3)
  }
  
  func testAddOrUpdateExistedRecords() {
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!
    
    let f1 = makeEntityWithNumber(1)
    let f2 = makeEntityWithNumber(2)
    let f3 = makeEntityWithNumber(3)
    moc.insertObject(f1)
    moc.insertObject(f3)
    moc.insertObject(f2)
    
    CoreDataHelper.sharedInstance().saveContext()
    var request: NSFetchRequest
    var records: [FriendEntity]?
    
    let f4 = makeEntityWithNumber(4)
    let f5 = makeEntityWithNumber(5)


  }
  
}
