/// File: PersistenceStoreProvider.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 25.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public protocol PersistenceStoreProvider {
   var facebookAccesToken: String? {get set}
}
