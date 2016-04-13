//
//  Row.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/7/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class Row: NSObject {
    
    var id: String!
    var title: String!
    var books = [Book]()
    var bookIDs = [String]()
    
    init(dict: NSDictionary, nextIndex: Int) {
        
        super.init()
        
        if let name = dict["name"] as? String {
            self.title = name
        }
        
        if let ids = dict["bookIds"] as? String {
            self.bookIDs = ids.componentsSeparatedByString(",")
        }
        
        if let books = dict["bookData"] as? [NSDictionary] {
            for each in books {
                self.books.append(Book(dict: each))
            }
        }
        
        if let category = dict["categoryId"] as? String {
            if let id = Int(category) {
                let current = MyNetwork.instance().categories[id > 2 ? id - 1: id]
                if nextIndex == -1 {
                    current.fetchedAllRows = true
                } else {
                    current.nextIndex = nextIndex
                }
                current.rows.append(self)
            }
        }
        
    }

}
