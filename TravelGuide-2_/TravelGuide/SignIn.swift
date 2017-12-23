//
//  SignIn.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/23/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class SignIn: UIViewController {
    @IBOutlet var centerAlignUsername:UITextField!
    @IBOutlet var centerAlignPassword: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var forgotpassword: UILabel!
    
    @IBAction func login(sender: UIButton) {
        
        let userEmail = centerAlignUsername.text
        let userPassword = centerAlignPassword.text
        
        if(userEmail!.isEmpty && userPassword!.isEmpty )
        {
            displayAlertMessage("All fields are required to fill in")
            return
        }
        
        if(userEmail!.isEmpty || userPassword!.isEmpty)
        {
            
            let bounds = self.loginButton.bounds
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options:[], animations: {
                self.loginButton.bounds = CGRect(x: bounds.origin.x - 10, y: bounds.origin.y, width: bounds.size.width + 15, height: bounds.size.height)
                }, completion:
                {
                    animationFinished in
                    self.loginButton.bounds = CGRect(x: bounds.origin.x , y: bounds.origin.y, width: bounds.size.width , height: bounds.size.height)
            })
            return
        }
        
        if(!isValidEmail(userEmail!))
        {
            displayAlertMessage("Invalid email address!")
            return
        }
        
        if(!isValidPassword(userPassword!))
        {
            displayAlertMessage("Invalid password!")
            return
        }
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.dimBackground = true
        spinningActivity.animationType = MBProgressHUDAnimation.Fade
        spinningActivity.label.text = "Loading"
        spinningActivity.detailsLabel.text = "Please wait"
        
        
        let myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/userSignIn.php")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        let postString = "userEmail=\(userEmail!)&userPassword=\(userPassword!)"
        
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
                            NSUserDefaults.standardUserDefaults().setObject("normal", forKey: "type")
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
                            self.performSegueWithIdentifier("mainseague", sender: nil)
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
    
    
    func displayAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title: "Alert", message:userMessage, preferredStyle: .Alert);
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.dismissViewControllerAnimated(true,completion: nil)
        }
        
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        centerAlignUsername.center.x -= self.view.bounds.width
        centerAlignPassword.center.x -= self.view.bounds.width
        loginButton.alpha = 0.0
        centerAlignPassword.alpha=0.0
        centerAlignUsername.alpha=0.0
        forgotpassword.alpha=0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignIn.tapFunction))
        forgotpassword.userInteractionEnabled = true
        forgotpassword.addGestureRecognizer(tap)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController!.navigationBarHidden = false
        self.navigationItem.title = "Sign In"
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKindOfClass(SignUp) {
                controller.removeFromParentViewController()
                self.navigationController!.navigationBar.topItem!.title = "Back"         
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.0, delay: 0.3, options:.CurveEaseOut, animations: {
            self.centerAlignPassword.alpha=1.0
            self.centerAlignUsername.alpha=1.0
            self.centerAlignUsername.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.6, options: .CurveEaseOut, animations: {
            self.centerAlignPassword.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.8, options: .CurveEaseOut, animations: {
            self.loginButton.alpha = 1
            }, completion:
            {
                animationFinished in
                self.forgotpassword.alpha=1
        })
    }

    
    func tapFunction(sender:UITapGestureRecognizer)
    {
        print("tap working")
        self.performSegueWithIdentifier("forgotpasswordseague", sender: nil)
    }

    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidPassword(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,10}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func userTappedBackground(gestureRecognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
}