/// File: ImageDownloadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class ImageDownloadState {
  
  enum StateIdentifier: String {
    case Unknown = "Unknown", Initial = "Initial"
    case DownloadingImage = "DownloadingImage"
    case LoadSuccessed = "LoadSuccessed", LoadFailed = "LoadFailed"
  }
  
  var stateID: StateIdentifier {
    return .Unknown
  }
  
  func performOperation(context: ImageDownloadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  class Helper {
    class func reportError(context: ImageDownloadManager, error: NSError) {
      context.lastOperationError = error
      context.state = ImageDownloadStateLoadFailed()
      context.state.performOperation(context)
    }
  }
  
}

class ImageDownloadStateInitial: ImageDownloadState {
  override var stateID: StateIdentifier {
    return .Initial
  }
  
  override func performOperation(context: ImageDownloadManager) {
    context.downloadResults.removeAll(keepCapacity: true)
    context.state = ImageDownloadStateDownloadingImage()
    context.state.performOperation(context)
  }
}

class ImageDownloadStateDownloadingImage: ImageDownloadState {
  override var stateID: StateIdentifier {
    return .DownloadingImage
  }
  
  override func performOperation(context: ImageDownloadManager) {
    if let downloadTask = context.fetchTask.first {
      var task = context.backendManager.photoDownloadTask(downloadTask.downloadURL,
        success: {
          (image: UIImage) -> Void in
          let result = ImageDownloadManager.FetchResult()
          result.image = image
          result.downloadID = downloadTask.downloadID
          context.downloadResults.append(result)
          context.fetchTask.removeAtIndex(0)
          if context.fetchTask.count > 0 {
            context.state = ImageDownloadStateDownloadingImage()
            context.state.performOperation(context)
          } else {
            context.state = ImageDownloadStateLoadSuccessed()
            context.state.performOperation(context)
          }
        },
        failure: {
          (error: NSError) -> Void in
          ImageDownloadState.Helper.reportError(context, error: error)
        }
      )
      task.resume()
    } else {
      ImageDownloadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
    }
  }
}

class ImageDownloadStateLoadFailed: ImageDownloadState {
  override var stateID: StateIdentifier {
    return .LoadFailed
  }
  
  override func performOperation(context: ImageDownloadManager) {
    assert(context.lastOperationError != nil)
    context.failureCallback(context.lastOperationError!)
  }
}

class ImageDownloadStateLoadSuccessed: ImageDownloadState {
  override var stateID: StateIdentifier {
    return .LoadSuccessed
  }
  
  override func performOperation(context: ImageDownloadManager) {
    assert(context.fetchTask.count == 0)
    context.successCallback(context.downloadResults)
  }
}

public class ImageDownloadManager {
  
  public class FetchTask {
    public var downloadURL: NSURL!
    public var downloadID: String!
    public init() {
    }
  }
  
  public class FetchResult {
    public var downloadID: String!
    public var error: NSError?
    public var image: UIImage?
  }
  
  public var downloadResults = [FetchResult]()
  
  var fetchTask = [FetchTask]()
  
  var lastOperationError: NSError?
  
  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()
  
  var state: ImageDownloadState = ImageDownloadStateInitial() {
    didSet {
      logVerbose("State changed: \(oldValue.stateID.rawValue) => \(self.state.stateID.rawValue).")
    }
  }
  
  var stateID: ImageDownloadState.StateIdentifier {
    return self.state.stateID
  }
  
  var successCallback: ([FetchResult] -> Void)!
  var failureCallback: (NSError -> Void)!
  
  public init() {
  }
  
  public func downloadImages(fetchTask: [FetchTask], success: (results:[FetchResult]) -> Void, failure: (error:NSError) -> Void) {
    self.successCallback = success
    self.failureCallback = failure
    self.fetchTask = fetchTask
    self.state = ImageDownloadStateInitial()
    self.state.performOperation(self)
  }
  
}
