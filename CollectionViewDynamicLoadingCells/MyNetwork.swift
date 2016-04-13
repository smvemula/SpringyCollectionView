
//
//  MyNetwork.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/1/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation
import UIKit

public enum HTTPMethod: String {
    case GET = "GET", POST = "POST", PUT = "PUT", DELETE = "DELETE"
}

public class MyNetwork:NSObject, NSURLSessionDataDelegate {
    
    let urlSession: NSURLSession = NSURLSession.sharedSession()
    var task : NSURLSessionDataTask?
    var hostURL = ""
    var categories = [Category]()
    var activeCategories = [Category]()
    var nextIndex = 0
    var Rows = [String: [Book]]()
    var currentSection = 0
    
    required public override init() {
        super.init()
    }
    
    //singleton for network instance
    public class func instance() -> MyNetwork {
        struct Static {
            static var instance: MyNetwork? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = self.init()
        }
        
        return Static.instance!
    }
}


//MARK: Public API
extension MyNetwork {

    //with uniform resource identifier
    public func requestWithUri(uri:String,
        httpMethod: HTTPMethod,
        httpBodyParameters:AnyObject?,
        completion: ((String, AnyObject?, NSError?) -> Void)!){
            _request(uri, httpMethod: httpMethod, httpBody: httpBodyParameters, shouldAppendURL: true, completion: completion)
    }
    
    public func requestWithUri(uri:String,
        httpMethod: HTTPMethod,
        httpBodyParameters:AnyObject?,
        isJSONObject:Bool,
        completion: ((String, AnyObject?, NSError?) -> Void)!){
            _request(uri, httpMethod: httpMethod, httpBody: httpBodyParameters, shouldAppendURL: true, isJSONObject : isJSONObject,completion: completion)
    }
    
    //with uniform resource locator
    public func requestWithUrl(url:String,
        httpMethod: HTTPMethod,
        httpBodyParameters:AnyObject?,
        completion: ((String, AnyObject?, NSError?) -> Void)){
            _request(url, httpMethod: httpMethod, httpBody: httpBodyParameters, shouldAppendURL: false, completion: completion)
    }
    
}

//MARK: Private Methods
extension MyNetwork {
    
    private func _request(target:String,
        httpMethod:HTTPMethod,
        httpBody: AnyObject?,
        shouldAppendURL : Bool,
        isJSONObject : Bool,
        completion: ((String, AnyObject?, NSError?) -> Void)!)
    {
        var url : String = target
        if shouldAppendURL {
            url = "\(self.hostURL)\(target)"
            //if self.isLoggedIn() {
                //url = "\(self.loggedInURL)\(target)"
            //}
        }
        print("Outgoing URL : \(url)")
        if let encodedURLString = (url as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding){
            let request = buildHttpRequest(encodedURLString, httpBody: httpBody, isJSONObject : isJSONObject, httpMethod: httpMethod)
            print(request.allHTTPHeaderFields)
            task = urlSession.dataTaskWithRequest(request) {(data, response, error) in
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                }
                
                var status : String = ""
                var content : AnyObject? = nil
                if error != nil {
                    print("HTTP request error code:\(status) : \(error!.localizedDescription),\(error!.localizedRecoverySuggestion) , for URL: \(url)")
                    status = "-999" //network error
                    completion(status, nil, error)
                } else {
                    let _: NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    (status, content) = NSJSONSerialization.parseBasicResponse(data!)
                    if let contentExists: AnyObject = content{
                        if let _ = contentExists as? NSDictionary{
                            //print("content as Dictionary : \(contentAsDictionary)")
                        }
                        
                        if let _ = contentExists as? NSString{
                            //print("content as String : \(contentAsString)")
                        }
                        
                        if let _ = contentExists as? NSArray{
                            //print("content as Array : \(contentAsArray)")
                        }
                        
                        completion(status, contentExists, nil)
                    }
                }
            }
            
            if let exists = task {
                exists.resume()
            }
        }
    }
    
    private func _request(target:String,
        httpMethod:HTTPMethod,
        httpBody: AnyObject?,
        shouldAppendURL : Bool,
        completion: ((String, AnyObject?, NSError?) -> Void)!)
    {
        _request(target, httpMethod: httpMethod, httpBody: httpBody, shouldAppendURL: shouldAppendURL, isJSONObject : false, completion: completion)
    }
    
    public func buildHttpRequest(urlString: String,
        httpBody: AnyObject?,
        isJSONObject : Bool,
        httpMethod: HTTPMethod) -> NSMutableURLRequest {
            
            if let url = NSURL(string: urlString){
                
                let request = NSMutableURLRequest(URL:url)
                request.HTTPMethod = httpMethod.rawValue
                
                
                // Headers
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                if let bodyParams = httpBody as? NSDictionary {
                    //var error: NSError?
                    
                    if let body: NSString = bodyParams.contentsAsURLQueryString(){
                        if isJSONObject {
                            do {
                                let value = try NSJSONSerialization.dataWithJSONObject(bodyParams, options: [])
                                request.HTTPBody = value
                            }
                                
                            catch let error as NSError {
                                print("HTTPBODY : A JSON Object build error occurred, here are the details:\n \(error)")
                            }

                        } else {
                            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
                        }
                    }
                    else{
                        
                        do {
                            let value = try NSJSONSerialization.dataWithJSONObject(bodyParams, options: [])
                            request.HTTPBody = value
                        }
                            
                        catch let error as NSError {
                            print("HTTPBODY : A JSON Object build error occurred, here are the details:\n \(error)")
                        }
                    }
                    
        
                    
                } else if let bodyParams = httpBody as? NSArray {
                    
                    do {
                        let value = try NSJSONSerialization.dataWithJSONObject(bodyParams, options: [])
                        request.HTTPBody = value
                    }
                        
                    catch let error as NSError {
                        print("HTTPBODY : A JSON Object build error occurred, here are the details:\n \(error)")
                    }
                }
                else if let bodyParams = httpBody as? NSString{
                    //var error: NSError?
                    if let body = bodyParams.dataUsingEncoding(NSUTF8StringEncoding) {
                        request.HTTPBody = body
                    }
                }
                else if let bodyParams = httpBody as? NSData {
                    request.HTTPBody = bodyParams
                }
                else if let bodyParams = httpBody as? Bool {
                    let booleanString = bodyParams ? "true" : "false"
                    request.HTTPBody = booleanString.dataUsingEncoding(NSUTF8StringEncoding)
                }
                
                return request
            }
            return NSMutableURLRequest()
    }
    
    private func _buildHttpRequest(urlString: String,
        httpBody: AnyObject?,
        httpMethod: HTTPMethod) -> NSMutableURLRequest {
            return buildHttpRequest(urlString, httpBody: httpBody, isJSONObject : false, httpMethod: httpMethod)
    }
    
}

extension MyNetwork {
    
    func startObjeservingForNotificationName(name: String) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyNetwork.notificationRecieved(_:)), name: name, object: nil)
    }
    
    func postForNotificationName(name: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
    }
    
    func postForNotificationName(name: String, data: Dictionary<String,String>) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: data)
    }
    
    func notificationRecieved(notification: NSNotification) {
    }
}

