//
//  aboutus.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/29/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class aboutus: UIViewController
{

    @IBOutlet var mywebview:UIWebView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController!.navigationBarHidden = false
        self.navigationItem.title = "About Us"
        self.navigationItem.setHidesBackButton(true, animated:true)
    
        let url = NSURL (string: "http://iosgroupmap15.x10host.com/inc/aboutus.html")
        let requestObj = NSURLRequest(URL: url!)
        mywebview!.loadRequest(requestObj)
    }

    @IBAction func leftSideButtonTapped(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }


}