//
//  UIAlertViewExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/10/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation
import UIKit

extension UIAlertView {
    class func showAlertViewNetworkIssues(vc: UIViewController) {
        self.showAlertView(NSLocalizedString("Error !!", comment: "Error !!"), text: NSLocalizedString("Network error.", comment: "Network error."), vc: vc)
    }
    
    class func showWorkInProgress(vc: UIViewController) {
        self.showAlertView("!!!Work in Progress!!!", text: "STAY TUNED!", vc: vc)
    }
    
    class func showAlertView(title: String, text: String, vc: UIViewController) {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { action in
            }))
            vc.presentViewController(alert, animated: true, completion: nil)
        } else {
            print("\(title) : \(text)")
        }
    }
    
    class func showShareAlertIn(vc: UIViewController) {
        let alert = UIAlertController(title: "Share & Earn", message: "You can earn cash by sharing Bet On app URL to your friends or Inviting new friends to Bet On!.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancel)
        let share = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: {(alertAction) -> Void in
            if let tab = vc.presentingViewController as? UITabBarController {
                vc.dismissViewControllerAnimated(true, completion: {
                    tab.selectedIndex = 2
                })
            } else if let tab = vc.tabBarController {
                tab.selectedIndex = 2
                
            }
        })
        alert.addAction(share)
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showAlertView(title: String, message: String, cancelButtonTitle: String, actionButtonTitle: String, actionButtonBlock: () -> (), vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: actionButtonTitle, style: UIAlertActionStyle.Default, handler: { action in
            actionButtonBlock()
        }))
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: { action in
        }))
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func notifyImportantEvents(title: String, message: String, vc: UIViewController) {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            UIAlertView.showAlertView(title, text: message, vc: vc)
        } else {
            let notification = UILocalNotification() // create a new reminder notification
            notification.alertTitle = title
            notification.alertBody = message
            notification.fireDate = NSDate().dateByAddingTimeInterval(0)
            notification.soundName = UILocalNotificationDefaultSoundName // play default soundr
            notification.category = "Feedback"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    class func showAlertView(title: String, text: String) {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            let alertTitle = NSLocalizedString(title, comment: title)
            let alertText = NSLocalizedString(text, comment: text)
            let alertView = UIAlertView(title: alertTitle, message: NSLocalizedString(alertText, comment: alertText), delegate: nil, cancelButtonTitle:NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        } else {
            print("\(title) : \(text)")
        }
    }
}
