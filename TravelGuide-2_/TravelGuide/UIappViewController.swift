//
//  UIappViewController.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/12/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import Foundation
import UIKit

class UIappViewController: UIViewController,AppManagerDelegate {
    var manager:AppManager = AppManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reachabilityStatusChangeHandler(reachability: Reachability) {
        if reachability.isReachable() {
            print("isReachable")
        } else {
            let alertController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet an try again", preferredStyle: .Alert)
            
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
            
            // Create the actions
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                UIAlertAction in
                UIControl().sendAction(#selector(NSURLSessionTask.suspend), to: UIApplication.sharedApplication(), forEvent: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
                exit(0)
                
            }
            
            // Add the actions
            alertController.addAction(okAction)
            
            // Present the controller
            
            let topVC: UIViewController = getCurrentViewController()!
            topVC.presentViewController(alertController, animated: true, completion: nil)
        
            print("notReachable")
        }
    }
    
    
    func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    // Returns the navigation controller if it exists
    func getNavigationController() -> UINavigationController? {
        
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            
            return navigationController as? UINavigationController
        }
        return nil
    }
}