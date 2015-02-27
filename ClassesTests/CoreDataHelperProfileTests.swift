/// File: CoreDataHelperProfileTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 17.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import XCTest
import FBPVClasses
import CoreData


class CoreDataHelperProfileTests: XCTestCase {
  
  func testProfileActions() {
    var moc = CoreDataHelper.sharedInstance().managedObjectContext!
    var request = CoreDataHelper.Profile.sharedInstance.fetchRequestForProfile
    var results = CoreDataHelper.Profile.fetchRecordsAndLogError(request)
    XCTAssertNotNil(results)
    XCTAssertTrue(results!.count == 0)
    
    var p = CoreDataHelper.Profile.makeEntityInstance()
    p.userName = "Profile 1"
    moc.insertObject(p)
    CoreDataHelper.sharedInstance().saveContext()
    results = CoreDataHelper.Profile.fetchRecordsAndLogError(request)
    XCTAssertNotNil(results)
    XCTAssertTrue(results!.count == 1)
    XCTAssertTrue(results!.first! == p)
    
  }
   
}
