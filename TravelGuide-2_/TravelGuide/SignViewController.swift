//
//  SignViewController.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/12/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit
import TNImageSliderViewController
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class SignViewController: UIappViewController,FBSDKLoginButtonDelegate , GIDSignInUIDelegate ,GIDSignInDelegate{
    @IBOutlet var email:UIButton?
    @IBOutlet var facebook:UIButton?
    @IBOutlet var signUp: UILabel!
    @IBOutlet var google:UIButton?
    
    @IBOutlet weak var loginbutton: FBSDKLoginButton!
    var reachability:Reachability?
    var imageSliderVC:TNImageSliderViewController!
    var userID : String?
    
    var fbEmail:String? = nil
    var fbFirstName:String? = nil
    var fbLastName:String? = nil
    var data:NSData?
    var imageStore: ImageStore!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if( segue.identifier == "seg_imageSlider" )
        {
          imageSliderVC = segue.destinationViewController as! TNImageSliderViewController
        }
    }
    
        override func viewDidLoad() {
        super.viewDidLoad()
            
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            self.imageStore = appDelegate.imageStore
            
            let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            spinningActivity.dimBackground = true
            spinningActivity.animationType = MBProgressHUDAnimation.Fade
            spinningActivity.label.text = "Loading"
            spinningActivity.detailsLabel.text = "Please wait"
            
            let imageUrl = NSURL(string:"http://iosgroupmap15.x10host.com/inc/1.jpg")
            let imageUrl2 = NSURL(string:"http://iosgroupmap15.x10host.com/inc/2.jpg")
            let imageUrl3 = NSURL(string:"http://iosgroupmap15.x10host.com/inc/3.jpg")
            let imageUrl4 = NSURL(string:"http://iosgroupmap15.x10host.com/inc/4.jpg")
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            dispatch_async(backgroundQueue, {
                print(NSData(contentsOfURL: imageUrl!))
                if let imageData = NSData(contentsOfURL: imageUrl!)
                {
                    print(imageData)
                    dispatch_sync(dispatch_get_main_queue(),{
                        
                        self.imageStore!.setImage(UIImage(data: imageData)!, forKey: "Image-1")
                    });
                }
                
                if let imageData2 = NSData(contentsOfURL: imageUrl2!)
                {
                    dispatch_sync(dispatch_get_main_queue(),{
                        
                        self.imageStore!.setImage(UIImage(data: imageData2)!, forKey: "Image-2")
                    });
                }
            
                if let imageData3 = NSData(contentsOfURL: imageUrl3!)
                {
                    dispatch_sync(dispatch_get_main_queue(),{
                        
                        self.imageStore!.setImage(UIImage(data: imageData3)!, forKey: "Image-3")
                    });
                }
                
               if let imageData4 = NSData(contentsOfURL: imageUrl4!)
                {
                    dispatch_sync(dispatch_get_main_queue(),{
                        
                        self.imageStore!.setImage(UIImage(data: imageData4)!, forKey: "Image-4")
                        spinningActivity.hideAnimated(true)
                        let image1 = self.imageStore!.imageForKey("Image-1")
                        let image2 = self.imageStore!.imageForKey("Image-2")
                        let image3 = self.imageStore!.imageForKey("Image-3")
                        let image4 = self.imageStore!.imageForKey("Image-4")
                        if let image1 = image1, let image2 = image2, let image3 = image3,let image4 = image4
                        {
                            self.imageSliderVC.images = [image1, image2, image3,image4]
                            var options = TNImageSliderViewOptions()
                            options.pageControlHidden = false
                            options.scrollDirection = .Horizontal
                            options.pageControlCurrentIndicatorTintColor = UIColor.grayColor()
                            options.autoSlideIntervalInSeconds = 4
                            options.shouldStartFromBeginning = true
                            options.imageContentMode = .ScaleAspectFit
                            options.backgroundColor = UIColor.clearColor()
                            self.imageSliderVC.options = options
                        }
                        else
                        {
                            print("[ViewController] Could not find one of the images in the image catalog")
                        }
                    });
                }
                
                
            })
           print(imageStore.imageForKey("Image-1"))
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(SignViewController.tapFunction))
            signUp.userInteractionEnabled = true
            signUp.addGestureRecognizer(tap)
            
            manager.delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().delegate = self
            
            loginbutton.delegate=self
            loginbutton.readPermissions=["email","public_profile"]
            loginbutton.alpha=0
       }
        
      
    override func viewWillAppear(animated: Bool)
    {
       UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.navigationController!.navigationBarHidden = true
        email!.imageEdgeInsets=UIEdgeInsets(top: 0.0,left:0.0,bottom: 0.0,right:((email!.frame.size.width)/2)-10)
        facebook!.imageEdgeInsets=UIEdgeInsets(top: 0.0,left:0.0,bottom: 0.0,right:((facebook!.frame.size.width)/2)-10)
        google!.imageEdgeInsets=UIEdgeInsets(top: 0.0,left:0.0,bottom: 0.0,right:((google!.frame.size.width)/2)-10)    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapFunction(sender:UITapGestureRecognizer)
    {
        print("tap working")
        self.performSegueWithIdentifier("signupseague", sender: nil)
    }
    
    @IBAction func signin(sender: AnyObject)
    {}
    
    @IBAction func facebooksignin(sender: AnyObject)
    {
      loginbutton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil
        {
            print("error")
            return
        }
        else if((FBSDKAccessToken.currentAccessToken()) != nil)
        {
            print("successfully logged in")
            FBSDKGraphRequest(graphPath:"/me", parameters: ["fields":"id,name,email,first_name,last_name"]).startWithCompletionHandler(
                { (connection, result, error) -> Void in
                    if (error == nil)
                    {
                        print(result)
                        self.userID = result.valueForKey("id") as? String
                        self.fbEmail = result.valueForKey("email") as? String
                        self.fbFirstName = result.valueForKey("first_name") as? String
                        self.fbLastName = result.valueForKey("last_name") as? String
                
                        let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(self.userID!)/picture?type=small")
                        self.data = NSData(contentsOfURL:facebookProfileUrl!)
                                             // self.webview!.loadRequest(NSURLRequest(URL: facebookProfileUrl!))
                        
                        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        spinningActivity.dimBackground = true
                        spinningActivity.animationType = MBProgressHUDAnimation.Fade
                        spinningActivity.label.text = "Loading"
                        spinningActivity.detailsLabel.text = "Please wait"
                        
                        
                        let myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/fbUser.php")
                        let request = NSMutableURLRequest(URL:myUrl!)
                        request.HTTPMethod = "POST"
                        
                        let postString = "userEmail=\(self.fbEmail!)&userFirstName=\(self.fbFirstName!)&userLastName=\(self.fbLastName!)&userID=\(facebookProfileUrl!)"
                        
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
                        {
                            (Data, response, Error) -> Void in
                            dispatch_sync(dispatch_get_main_queue(),{
                                spinningActivity.hideAnimated(true)
                                if (Error != nil)
                                {
                                    self.displayAlertMessage(Error!.localizedDescription)
                                    return
                                }
                                
                                do
                                {
                                    let json = try NSJSONSerialization.JSONObjectWithData(Data!, options:.AllowFragments) as? NSDictionary
                                    print(json)
                                    if let parseJSON = json
                                    {
                                        
                                        let userId = parseJSON["userId"] as? String
                                        
                                        if( userId != nil)
                                        {
                                            NSUserDefaults.standardUserDefaults().setObject(parseJSON["userFirstName"], forKey: "userFirstName")
                                            NSUserDefaults.standardUserDefaults().setObject(parseJSON["userLastName"], forKey: "userLastName")
                                            NSUserDefaults.standardUserDefaults().setObject(parseJSON["userId"], forKey: "userId")
                                            NSUserDefaults.standardUserDefaults().setObject(parseJSON["userEmail"], forKey: "userEmail")
                                            NSUserDefaults.standardUserDefaults().setObject("fb", forKey: "type")
                                            NSUserDefaults.standardUserDefaults().synchronize()
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainviewcontroller") as! MainViewController
                                            let leftSideMenu:NavigationDrawer = storyboard.instantiateViewControllerWithIdentifier( "navigationdrawer") as!  NavigationDrawer
                                            let mainPageNav = UINavigationController(rootViewController: mainPage)
                                            //let menu = UINavigationController(rootViewController: leftSideMenu)
                                            
                                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                            appDelegate.drawerContainer  = MMDrawerController(centerViewController: mainPageNav, leftDrawerViewController: leftSideMenu)
                                            appDelegate.drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
                                            appDelegate.drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
                                            
                                            
                                            appDelegate.window?.rootViewController = appDelegate.drawerContainer
                                            
                                            self.imageStore.setImage(UIImage(data:self.data!)!, forKey: userId!)
                                            
                                            self.performSegueWithIdentifier("mainscreenseague", sender: nil)
                                        }
                                        else
                                        {
                                            let errorMessage = parseJSON["message"] as? String
                                            if(errorMessage != nil)
                                            {
                                                self.displayAlertMessage(errorMessage!)
                                            }
                                        }
                                    }
                                }
                                catch
                                {
                                    print(error)
                                    return
                                }
                            });
                        }
                        
                        task.resume()
                        
                    }
            })
            let manager = FBSDKLoginManager()
            manager.logOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
            FBSDKProfile.setCurrentProfile(nil)
        }
    }
    
    func displayAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title: "Alert", message:userMessage, preferredStyle: .Alert);
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.dismissViewControllerAnimated(true,completion: nil)
        }
        
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated: true,completion: nil)
        
    }


    @IBAction func googlesignin(sender: AnyObject)
    {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("FB log out")
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil)
        {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            let imagesize=CGSizeMake(130,50)
            var pic :NSURL? = nil
            if(GIDSignIn.sharedInstance().currentUser.profile.hasImage)
            {
                let dimension:UInt = UInt(round(imagesize.width * UIScreen.mainScreen().scale))
                pic = user.profile.imageURLWithDimension(dimension)
                self.data = NSData(contentsOfURL:pic!)
                print(pic)
                // let requestObj = NSURLRequest(URL: pic)
                
                // let vc = self.window?.rootViewController as! ViewController
                // vc.webpic(requestObj)
                
            }
            let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            spinningActivity.dimBackground = true
            spinningActivity.animationType = MBProgressHUDAnimation.Fade
            spinningActivity.label.text = "Loading"
            spinningActivity.detailsLabel.text = "Please wait"
            
            
            let myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/twUser.php")
            
            
            let request = NSMutableURLRequest(URL:myUrl!)
            request.HTTPMethod = "POST"
            
            let postString = "userEmail=\(email)&userFirstName=\(givenName)&userLastName=\(familyName)&userID=\(pic!)"
            
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
            {
                (Data, response, Error) -> Void in
                dispatch_sync(dispatch_get_main_queue(),{
                    spinningActivity.hideAnimated(true)
                    if (Error != nil)
                    {
                        self.displayAlertMessage(Error!.localizedDescription)
                        return
                    }
                    
                    do
                    {
                        let json = try NSJSONSerialization.JSONObjectWithData(Data!, options:.AllowFragments) as? NSDictionary
                        print(json)
                        if let parseJSON = json
                        {
                            
                            let userId = parseJSON["userId"] as? String
                            
                            if( userId != nil)
                            {
                                NSUserDefaults.standardUserDefaults().setObject(parseJSON["userFirstName"], forKey: "userFirstName")
                                NSUserDefaults.standardUserDefaults().setObject(parseJSON["userLastName"], forKey: "userLastName")
                                NSUserDefaults.standardUserDefaults().setObject(parseJSON["userId"], forKey: "userId")
                                NSUserDefaults.standardUserDefaults().setObject(parseJSON["userEmail"], forKey: "userEmail")
                                NSUserDefaults.standardUserDefaults().setObject("google", forKey: "type")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                
                                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainviewcontroller") as! MainViewController
                                let leftSideMenu:NavigationDrawer = storyboard.instantiateViewControllerWithIdentifier( "navigationdrawer") as!  NavigationDrawer
                                let mainPageNav = UINavigationController(rootViewController: mainPage)
                                //let menu = UINavigationController(rootViewController: leftSideMenu)
                                
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.drawerContainer  = MMDrawerController(centerViewController: mainPageNav, leftDrawerViewController: leftSideMenu)
                                appDelegate.drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
                                appDelegate.drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
                                
                                
                                appDelegate.window?.rootViewController = appDelegate.drawerContainer
                                self.imageStore.setImage(UIImage(data: self.data!)!, forKey: userId!)
                                self.performSegueWithIdentifier("mainscreenseague", sender: nil)
                            }
                            else
                            {
                                let errorMessage = parseJSON["message"] as? String
                                if(errorMessage != nil)
                                {
                                    self.displayAlertMessage(errorMessage!)
                                }
                            }
                        }
                    }
                    catch
                    {
                        print(error)
                        return
                    }
                });
            }
        
            task.resume()
            print(userId+idToken+fullName+givenName+familyName+email)
            GIDSignIn.sharedInstance().disconnect()
        }
    else
        {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!)
    {
        // Perform any operations when the user disconnects from app here.
        print("sign out")
    }
    
    
}

