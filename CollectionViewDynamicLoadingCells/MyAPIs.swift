//
//  MyAPIs.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 8/16/15.
//  Copyright © 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import Foundation

class MyAPIs: NSObject {
    
    class func getData(categoryID: Int, completion: ()-> ()) {
        //http://dev.storymagic.co/max/api/?class=Category&dev=iPhone&loc=en_US&method=getContentRowsForSection&sectionId=1&sig=9b35c658ac115a4d0133ccd86b3b240f&time=2016-04-06%2018%3A45%20-0700&userId=8994&ver=2.0&pageIndex=11
        
        let current = MyNetwork.instance().categories[categoryID]
        MyNetwork.instance().requestWithUrl("http://dev.storymagic.co/max2/api/?class=Category&dev=iPhone&loc=en_US&method=getContentRowsForSection&sectionId=\(current.id)&sig=9b35c658ac115a4d0133ccd86b3b240f&time=2016-04-06%2018%3A45%20-0700&userId=8994&ver=2.0&pageIndex=\(current.nextIndex)", httpMethod: HTTPMethod.POST, httpBodyParameters: [], completion: {(status, content, error) -> Void in
            if let dict = content as? NSDictionary {
                if let result = dict["result"] as? NSDictionary {
                    if let rows = result["UserCategory"] as? [NSDictionary] {
                        if let index = result["nextUserCategoryRowIndex"] as? Int {
                            for each in rows {
                                Row(dict: each, nextIndex: index)
                            }
                        }
                    }
                }
                completion()
            }
        })
    }
    
    class func getSections(completion: ()->()) {
        
        MyNetwork.instance().requestWithUrl("http://dev.storymagic.co/max2/api/?class=Sync&dev=iPhone&loc=en_US&method=getContentSections&sig=82a93e573f58e84a18990c168b9d4563&time=2016-04-07%2015:56%20-0700&userId=8994&ver=2.0", httpMethod: HTTPMethod.POST, httpBodyParameters: [], completion: {(status, content, error) -> Void in
        if let dict = content as? NSDictionary {
            if let result = dict["result"] as? NSDictionary {
                if let sections = result["ContentSection"] as? [NSDictionary] {
                    for each in sections {
                        if let params = each["params"] as? NSDictionary {
                            if let _ = params["sectionId"] as? Int {
                                MyNetwork.instance().categories.append(Category(dict: each))
                            }
                        }
                    }
                    var categories = MyNetwork.instance().categories
                    MyNetwork.instance().categories = MyNetwork.instance().categories.sort({ return $1.id > $0.id})
                    categories = MyNetwork.instance().categories
                    print(categories)
                }
            }
        }
            completion()
        })
    }
}

extension MyAPIs {
    class func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            //            var part = NSString(format: "%@=%@",
            //                name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
            //                value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            //            parts.append(part as String)
            let part = NSString(format: "%@=%@",
                name,
                value)
            parts.append(part as String)
        }
        return parts.joinWithSeparator("&")
    }
    
    /**
    Creates a new URL by adding the given query parameters.
    @param URL The input URL.
    @param queryParameters The query parameter dictionary to add.
    @return A new NSURL.
    */
    class func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString, MyAPIs.stringFromQueryParameters(queryParameters))
        return NSURL(string: URLString as String)!
    }
}
