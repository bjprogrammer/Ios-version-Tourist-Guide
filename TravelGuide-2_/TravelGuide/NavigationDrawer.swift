//
//  NavigationDrawer.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/28/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class NavigationDrawer: UIViewController,UITableViewDataSource, UITableViewDelegate  {
    
    var menuItems:[String] = ["Main Menu","About Us","Profile","Sign Out"]
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var name:UILabel?
    let userId:String? = NSUserDefaults.standardUserDefaults().stringForKey( "userId")
    var imageStore: ImageStore!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let image = UIImageView(frame: CGRectMake(0, 0, 80, 80))
        imageView!.contentMode=UIViewContentMode.ScaleAspectFill
        imageView!.layer.borderWidth = 1.5
        imageView!.layer.masksToBounds = false
        imageView!.layer.borderColor = UIColor.whiteColor().CGColor
        imageView!.layer.cornerRadius = image.frame.width/2
        imageView!.clipsToBounds = true
        name?.text =  NSUserDefaults.standardUserDefaults().stringForKey("userFirstName")! + " " + NSUserDefaults.standardUserDefaults().stringForKey("userLastName")!
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.imageStore = appDelegate.imageStore
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        print(imageStore)
        if(imageStore!.imageForKey(userId!) != nil)
        {
        imageView!.image = imageStore!.imageForKey(userId!)
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexpath: NSIndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCellWithIdentifier("myCell")
        
        myCell!.textLabel?.text = menuItems[(indexpath).row]
        
        switch((indexpath).row)
        {
        case 0:
        let image : UIImage = UIImage(named: "Image-15")!
        //println("The loaded image: \(image)")
        myCell!.imageView!.image = image
        
        return myCell!
            
        case 1:
            
            let image : UIImage = UIImage(named: "Image-14")!
            //println("The loaded image: \(image)")
            myCell!.imageView!.image = image
            
            return myCell!
            
        case 2:
            
            let image : UIImage = UIImage(named: "Image-17")!
            //println("The loaded image: \(image)")
            myCell!.imageView!.image = image
            
            return myCell!
            
        case 3:
            let image : UIImage = UIImage(named: "Image-16")!
            //println("The loaded image: \(image)")
            myCell!.imageView!.image = image
            
            return myCell!
            
        default:
            print("error")
            return myCell!
        }
            
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexpath: NSIndexPath)
    {
        print(indexpath.row)
        switch((indexpath).row)
        {
        case 0:
            let mainPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainviewcontroller") as! MainViewController
            let mainPageNav = UINavigationController(rootViewController: mainPageViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.drawerContainer!.centerViewController = mainPageNav
            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break
            
        case 1:
            let aboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("aboutviewcontroller") as! aboutus
            let aboutPageNav = UINavigationController(rootViewController: aboutViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.drawerContainer!.centerViewController = aboutPageNav
            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break
            
        case 2:
            let updateProfileController = self.storyboard?.instantiateViewControllerWithIdentifier("updateprofilecontroller") as!
            updateprofile
            let aboutPageNav = UINavigationController(rootViewController: updateProfileController)
            
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = aboutPageNav
            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break
            
        case 3:
            NSUserDefaults.standardUserDefaults().removeObjectForKey( "userFirstName")
            NSUserDefaults.standardUserDefaults().removeObjectForKey( "userLastName")
            NSUserDefaults.standardUserDefaults().removeObjectForKey( "userId")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let signInPage = self.storyboard?.instantiateViewControllerWithIdentifier("navigate")
            let appDelegate = UIApplication.sharedApplication().delegate
            appDelegate?.window??.rootViewController = signInPage
            
        default:
            print("Not handled")
        }
    }
}
