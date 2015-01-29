//
//  Post.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 29.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import CoreData

class Post: NSManagedObject {

    @NSManaged var text: String
    @NSManaged var image: NSData

}
