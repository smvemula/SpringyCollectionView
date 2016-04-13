//
//  NSJSONSerializationExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 3/31/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation

public extension NSJSONSerialization {
    public class func parseIntFromJson(json:NSDictionary, key:String) -> Int {
        var result = 0
        if let value = json[key] as? Int {
            result = value
        }
        
        return result
    }
    
    public class func parseBoolFromJson(json:NSDictionary, key:String) -> Bool {
        var result = false
        if let value = json[key] as? Bool {
            result = value
        }
        
        return result
    }
    
    public class func parseStringFromJson(json:NSDictionary, key:String) -> String {
        var result = ""
        if let value = json[key] as? String {
            result = value
        }
        
        return result
    }
    
    public class func parseDictionaryFromJson(json:NSDictionary, key:String) -> NSDictionary {
        var result = NSDictionary()
        if let value = json[key] as? NSDictionary {
            result = value
        }
        
        return result
    }
    
    public class func parseArrayOfDictFromJson(json:NSDictionary, key:String) -> [NSDictionary] {
        var result = [NSDictionary]()
        if let value = json[key] as? [NSDictionary] {
            result = value
        }
        
        return result
    }
    
    
    
    public class func parseTimestampFromJson(json:NSDictionary, key:String) -> NSTimeInterval {
        var result = 0.0
        if let value = json[key] as? NSTimeInterval {
            result = value
        }
        return result
    }
    
    public class func parseBasicResponse(data:NSData) -> (status: String, content:AnyObject?) {
        var dictionary: NSDictionary?
        var array: NSArray?
        
        if let value =  _buildJsonDictionary(data) as? NSDictionary {
            dictionary = value
        } else if let value = _buildJsonArray(data) as? NSArray {
            array = value
            return parseBasicArrayResponse(array!)
        }
        else if let asString = NSString(data: data, encoding: NSUTF8StringEncoding){
            return ("0",asString)
        }
        else{
            print("invalid")
        }
        
        return parseBasicResponse(dictionary!)
    }
    
    public class func parseBasicResponse(requestDictionary:NSDictionary) -> (status: String, content:AnyObject?) {
        var status = "1"
        if let value = requestDictionary["status"] as? String {
            status = value
        }
        let content: AnyObject? = requestDictionary
        
        return (status, content)
    }
    
    
    public class func parseBasicArrayResponse(requestArray:NSArray) -> (status: String, content:AnyObject?) {
        var status = "1"
        if requestArray.count <= 0 {
            status = "0"
        }
        let content: AnyObject? = requestArray
        
        return (status, content)
    }
    
    
    
    public class func _buildJsonDictionary(data:NSData) -> AnyObject? {
        
        do {
            if case let JSON as NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) {
                return JSON
            }
        }
        
        
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("JSONDictionary : A JSON parsing error occurred, here are the details:\n \(error)")
        }
        
        /*
        var error: NSError?
        if let object = NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]], let dictionary = object.first {
            return dictionary
        } else {
            //let asString = NSString(data: data, encoding: NSUTF8StringEncoding)
            //print("ERROR Dictionary JSON: \(errorOccured)")
            print(error)
        }*/
        return nil
    }
    
    public class func _buildJsonArray(data:NSData) -> AnyObject? {
        
        do {
            if case let JSON as NSArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) {
                return JSON
            }
        }
            
            
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("JSONArray : A JSON parsing error occurred, here are the details:\n \(error)")
        }
        
        return nil
        /*
        var error: NSError?
        let object = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSArray
        if let errorOccured = error{
            //print("ERROR Array JSON: \(errorOccured)")
        }
        return object*/
    }
}