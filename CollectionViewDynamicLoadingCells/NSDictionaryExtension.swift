//
//  NSDictionaryExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 3/31/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation

extension NSDictionary {
    public func contentsAsURLQueryString() -> NSString? {
        let string: NSMutableString = ""
        let keys: [NSString] = self.allKeys as! [NSString]
        for key in keys {
            var value: AnyObject! = self.objectForKey(key)
            if value.isKindOfClass(NSString.self) {
                // value is a string
            } else if value.respondsToSelector(Selector("stringValue")) {
                value = value.stringValue
            } else {
                //bad parameters
                return nil
            }
            
            let parameterValue = key.isEqualToString("appID") ? value.description : value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
            let toAppend = key == "" ? parameterValue : "\(key)=\(parameterValue)"
            string.appendString(toAppend)
            
            if (keys.last != key) {
                string.appendString("&")
            }
        }
        return string;
    }
}