/// File: LoginScreenViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses

class LoginScreenViewController : UIViewController, UIWebViewDelegate {

  let FacebookLoginDialogErrorDomain = "FacebookLoginDialogErrorDomain"
  let FacebookLoginDialogErrorKeyScope = "FacebookLoginDialogErrorScope"

  @IBOutlet weak var webView: UIWebView!

  private var tokenInfo: (accessToken: String, expiresIn: Int)?
  private var error: NSError?
  var success: ((tokenInfo: (accessToken: String, expiresIn: Int)) -> ())?
  var canceled: (() -> ())?

  private var authorizationURL: NSURL? {
    if let infoPlist = NSBundle.mainBundle().infoDictionary {
      if let appID = infoPlist["WLFacebookAppID"] as? String {
        if let redirectURI = self.redirectURI {
          var queryElements = [
            "client_id=\(appID)",
            "redirect_uri=\(redirectURI)",
            "scope=public_profile,email,user_friends,user_birthday,user_hometown,user_friends,user_work_history,user_about_me,user_photos,publish_actions,read_stream",
            "response_type=token"]
          var query = NSURL.requestQueryFromParameters(queryElements)
          return NSURL(string: "https://www.facebook.com/dialog/oauth?\(query)")
        }
      }
    }
    return nil
  }

  private var redirectURI: String? {
    if let infoPlist = NSBundle.mainBundle().infoDictionary {
      return infoPlist["WLFacebookAppRedirectURI"] as? String
    } else {
      return nil
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.delegate = self

    var authURL = self.authorizationURL
    if let url = authURL {
      let request = NSURLRequest(URL: url, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 30)
      webView.loadRequest(request)
    }
  }

  deinit {
    webView.delegate = nil
  }

  private func complete() {
    if let cb = self.success {
      if let token = self.tokenInfo {
        cb(tokenInfo: token)
      }
    }
  }

  private func completeWithTokenInfo(tokenInfo: (accessToken: String, expiresIn: Int)) {
    logInfo("Success")
  }

  private func completeWithError(error: NSError) {
    logError(error)
  }

}

//MARK: - UIWebViewDelegate

extension LoginScreenViewController {

  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if let redirectURI = self.redirectURI {
      if let requestURLString = request.URL.absoluteString {
        if requestURLString.hasPrefix(redirectURI) {
          if let token = accessTokenFromURL(request.URL) {
            self.tokenInfo = token
          } else if let error = errorFromURL(request.URL) {
            self.error = error
          } else {
            logError("Unable to extract access token from URL: \(request.URL)")
          }
          logDebug("Redirect handled: \(request.URL)")
          dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            if let this = self {
              this.complete()
            }
          })
          return false
        }
      }
    }
    return true
  }

  func webViewDidStartLoad(webView: UIWebView) {
    logDebug("Loading...")
  }

  func webViewDidFinishLoad(webView: UIWebView) {
    logDebug("Done!")
  }

  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    if error.domain == "WebKitErrorDomain" && error.code == 102 { // WebKitErrorFrameLoadInterruptedByPolicyChange
      return
    }
    completeWithError(error)
  }

  private func accessTokenFromURL(url: NSURL) -> (accessToken: String, expiresIn: Int)? {
    var token: String?
    var expires: Int?

    if let fragment = url.fragment {
      let queryParameters = fragment.componentsSeparatedByString("&")
      for param in queryParameters {
        if param.hasPrefix("access_token=") {
          token = param.stringByReplacingOccurrencesOfString("access_token=", withString: "")
        } else if param.hasPrefix("expires_in=") {
          expires = param.stringByReplacingOccurrencesOfString("expires_in=", withString: "").toInt()
        }
      }
    }

    if token != nil && expires != nil {
      return (accessToken: token!, expiresIn: expires!)
    }

    return nil
  }

  private func errorFromURL(url: NSURL) -> NSError? {
    var error: String?
    var error_code: Int?
    var error_description: String?
    var error_reason: String?

    if let query = url.query {
      let q = query.stringByReplacingOccurrencesOfString("+", withString: " ")
      let queryParameters = q.componentsSeparatedByString("&")
      for param in queryParameters {
        if param.hasPrefix("error=") {
          error = param.stringByReplacingOccurrencesOfString("error=", withString: "")
        } else if param.hasPrefix("error_code=") {
          error_code = param.stringByReplacingOccurrencesOfString("error_code=", withString: "").toInt()
        }
        else if param.hasPrefix("error_description=") {
          error_description = param.stringByReplacingOccurrencesOfString("error_description=", withString: "")
        }
        else if param.hasPrefix("error_reason=") {
          error_reason = param.stringByReplacingOccurrencesOfString("error_reason=", withString: "")
        }
      }
    }

    if error != nil && error_code != nil && error_description != nil && error_reason != nil {
      let e = NSError(domain: FacebookLoginDialogErrorDomain, code: error_code!, userInfo:
        [NSLocalizedFailureReasonErrorKey: error_reason!,
          NSLocalizedDescriptionKey:error_description!,
          FacebookLoginDialogErrorKeyScope: error!])
      return e
    }
    
    return nil
  }
}