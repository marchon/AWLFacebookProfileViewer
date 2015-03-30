/// File: NSFetchedResultsChangeType.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 18.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import CoreData

public extension NSFetchedResultsChangeType {
  public var stringValue: String {
    switch self {
    case Insert:
      return "Insert"
    case Delete:
      return "Delete"
    case Move:
      return "Move"
    case Update:
      return "Update"
    }
  }
}
