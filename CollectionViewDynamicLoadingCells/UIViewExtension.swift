//
//  UIViewExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/2/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension UIView {
    public func startLoading(){
        self.startLoading(UIActivityIndicatorViewStyle.WhiteLarge, alpha: 0.9, message: "", fontSize: 17.0)
    }
    
    public func startLoadingWithText(message: String) {
        self.startLoading(UIActivityIndicatorViewStyle.WhiteLarge, alpha: 1, message: message, fontSize: 17.0)
    }
    
    public func startLoadingWithText(message: String, fontSize: CGFloat) {
        self.startLoading(UIActivityIndicatorViewStyle.WhiteLarge, alpha: 1, message: message, fontSize: fontSize)
    }
    
    //Used for cancelling the tune API call
    func canceltask() {
        if let taskRunning = MyNetwork.instance().task {
            if taskRunning.state == .Running {
                taskRunning.cancel()
            }
        }
        self.stopLoading()
    }
    
    public func addPulseEffect() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        self.layer.addAnimation(pulseAnimation, forKey: nil)
    }
    
    public func stopPulseEffect() {
        self.layer.removeAllAnimations()
    }
    
    public func startLoading(indicatorStyle: UIActivityIndicatorViewStyle, alpha:CGFloat, message: String, fontSize: CGFloat){
        
        self.stopLoading()
        dispatch_async(dispatch_get_main_queue(), {
            let loadingView = UIView(frame: self.bounds)
            loadingView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(alpha)
            loadingView.tag = 9999
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
            indicator.startAnimating()
            indicator.center = loadingView.center
            loadingView.addSubview(indicator)
            
            if message.utf16.count > 0 {
                let label = UILabel(frame: CGRectMake(15, indicator.frame.origin.y - 60, loadingView.frame.size.width - 30, 50))
                label.numberOfLines = 2
                label.textAlignment = NSTextAlignment.Center
                label.text = message
                loadingView.addSubview(label)
            }
            if let _ = self as? UITabBar {
                
            }/* else {
                let spinner = FeSpinnerTenDot(view: loadingView, withBlur: false)
                spinner.titleLabelText = "Loading"// ["Loading","Loading","Talking longer than normal","Complete"]
                spinner.fontTitleLabel = UIFont(name: "Helvetica-Neue", size: 25)
                spinner.show()
                loadingView.addSubview(spinner)
                //
            }*/
            
            
            
            if(!self.isLoading){
                self.addSubview(loadingView)
            }
        })
    }
    
    func drawBorder() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.colorWithHexString("#663300", andAlpha: 0.5).CGColor
    }
    
    public var isLoading: Bool{
        get{
            for view in self.subviews {
                if view.tag == 9999{
                    return true
                }
            }
            return false
        }
    }
    
    public func stopLoading(){
        
        var foundView:UIView?
        for view in self.subviews {
            if view.tag == 9999{
                foundView = view
            }
        }
        if let view = foundView{
            dispatch_async(dispatch_get_main_queue(), {
                view.removeFromSuperview()
            })
        }
        
    }
}