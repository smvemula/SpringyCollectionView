//
//  Book.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/7/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

protocol BookCoverDelegate {
    func updateCover()
}

class Book: NSObject {
    
    var title: String!
    var url: String!
    var id: String!
    var delegate: BookCoverDelegate?
    var imageData: NSData? {
        didSet {
            self.updateCell()
        }
    }
    
    func updateCell() {
        if let _ = imageData {
            if let exists = delegate {
                exists.updateCover()
            }
        }
    }
    
    var isBookVisible = false {
        didSet {
            if isBookVisible {
                if let _ = imageData {self.updateCell()}
                else if !self.isFetchingImage {
                    self.fetchImageData()
                }
            } else if self.isFetchingImage {
                self.cancelFetch()
            }
        }
    }
    
    private var isFetchingImage = false
    
    init(dict: NSDictionary) {
        if let id = dict["modelId"] as? String {
            self.id = id
            let mySubstring = self.id.substringFromIndex(self.id.endIndex.advancedBy(-1))
            self.url = "http://dev.storymagic.co/cdn/drm/\(mySubstring)/\(self.id)/cover.jpg"
            //http://dev.storymagic.co/cdn/drm/7/10637/cover.jpg
        }
        if let title = dict["title"] as? String {
            self.title = title
        }
    }
    
    var task : NSURLSessionTask?
    
    func fetchImageData() {
            /*if let _ = self.imageData {
                if let exists = self.delegate {
                    exists.updateCover()
                }
            } else {
                if !isFetchingImage {*/
                    //if let urlExists = self.url {
                        if let nsurl: NSURL = NSURL(string: self.url) {
                            // Download an NSData representation of the image at the URL
                            let request: NSURLRequest = NSURLRequest(URL: nsurl)
                            isFetchingImage = true
                            task = MyNetwork.instance().urlSession.dataTaskWithRequest(request){(data, response, error) in
                                self.isFetchingImage = false
                                if error == nil {
                                    self.imageData = data
//                                    if let completionExists = completion {
//                                        completionExists()
//                                    }
                                }
                                else {
                                    self.imageData = nil
                                    print("Error: \(error!.localizedDescription)")
                                }
                            }
                            
                            if let exits = task {
                                exits.resume()
                            }
                        }
                    //}
                //}
            //}
        }
    
    func cancelFetch() {
        if let isFetching = task {
            isFetching.cancel()
            task = nil
        }
    }
    

}
