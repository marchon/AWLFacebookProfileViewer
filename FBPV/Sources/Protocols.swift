/// File: Protocols.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 02.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

protocol ErrorReportingProtocol {
  func showErrorDialog(error: NSError)
}