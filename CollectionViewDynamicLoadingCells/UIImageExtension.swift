//
//  UIImageExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/3/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension UIImage {
    public class func createGradientImage(gradientLayer:CAGradientLayer,size:CGSize)->(UIImage){
        let gradientView = UIView(frame: CGRect(origin: CGPointZero, size: size))
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientLayer)
        UIGraphicsBeginImageContext(gradientView.bounds.size)
        gradientView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage
    }
    
    public class func defaultSmallImage()-> UIImage
    {
        //if we do have an image we will return the default small thumbnail image
        return UIImage(named: "defaultImage")!
    }
    
    public class func completionImageForString(percent:String)->(UIImage){
        let percentInt = Int(percent)
        
        var imageNamed = ""
        if(percentInt > 0 && percentInt <= 49){
            imageNamed = "CompletionRed"
        }
        else if(percentInt > 49 && percentInt <= 69 ){
            imageNamed = "CompletionYellow"
        }
        else{
            imageNamed = "CompletionGreen"
        }
        
        return UIImage(named: imageNamed)!
    }
    
    
    public func tintWithColor(tintColor : UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale)
        let drawRect = CGRectMake(0, 0, self.size.width, self.size.height)
        self.drawInRect(drawRect)
        tintColor.set()
        UIRectFillUsingBlendMode(drawRect, CGBlendMode.SourceAtop)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage;
    }
    
    public class func getBlurredImageWithSize(view: UIView) -> UIImage {
    // You will want to calculate this in code based on the view you will be presenting
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), afterScreenUpdates: true)
    //[view drawViewHierarchyInRect:(CGRect){CGPointZero, w, h} afterScreenUpdates:YES]; // view is the view you are grabbing the screen shot of. The view that is to be blurred.
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        // Gaussian Blur
        //image = image.//[image applyLightEffect];
    
    // Box Blur
    // image = [image boxblurImageWithBlur:0.2f];
        return image
    }
    
    public func getImageFromBase64String(base64String : String) -> UIImage {
        let _ = base64String
        if let url : NSURL = NSURL(string: "data:application/octet-stream;base64,\(base64String)"){
            do {
                let data:NSData = try NSData(contentsOfURL: url, options: [])
                return UIImage(data: data)!
            }
            
            catch {
                print("Error in fetching image from URL")
            }
        }
        return UIImage()
    }
    
    public func imageScaleWithImage(image : UIImage, newSize : CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
