//
//  Category.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/7/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class Category: NSObject {
    var id: Int!
    var title: String!
    var rows = [Row]()
    var currentIndex = 0
    var nextIndex = 0
    var fetchedAllRows = false
    
    init(dict: NSDictionary) {
        if let name = dict["name"] as? String {
            self.title = name
        }
        if let params = dict["params"] as? NSDictionary {
            if let id = params["sectionId"] as? Int {
                self.id = id
            }
        }
    }
}
