//
//  SignUp.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/12/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class SignUp: UIViewController {
    
    @IBOutlet var username:UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var firstname:UITextField!
    @IBOutlet var lastname: UITextField!
    @IBOutlet var repeatpassword: UITextField!
    
    @IBAction func signup(sender: UIButton)
    {
        let userEmail = username.text
        let userPassword = password.text
        let userPasswordRepeat = repeatpassword.text
        let userFirstName = firstname.text
        let userLastName = lastname.text
        
        if(userEmail!.isEmpty && userPassword!.isEmpty && userFirstName!.isEmpty && userLastName!.isEmpty)
        {
            displayAlertMessage("All fields are required to fill in")
            return
        }
        
        if(userEmail!.isEmpty || userPassword!.isEmpty || userFirstName!.isEmpty || userLastName!.isEmpty)
        {
            let bounds = self.signupButton.bounds
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options:[], animations:
                {
                    self.signupButton.bounds = CGRect(x: bounds.origin.x - 10, y: bounds.origin.y, width: bounds.size.width + 15, height: bounds.size.height)
                }, completion:
                {
                    animationFinished in
                    self.signupButton.bounds = CGRect(x: bounds.origin.x , y: bounds.origin.y, width: bounds.size.width , height: bounds.size.height)
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
            displayAlertMessage("Invalid password! Password must have 6-10 characters with atleast one special character")
            return
        }
        
        if( userPassword != userPasswordRepeat)
        {
            displayAlertMessage("Passwords do not match")
            return
        }
        
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.dimBackground = true
        spinningActivity.animationType = MBProgressHUDAnimation.Fade
        spinningActivity.label.text = "Loading"
        spinningActivity.detailsLabel.text = "Please wait"
        
        
        let myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/registerUser.php")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        let postString = "userEmail=\(userEmail!)&userFirstName=\(userFirstName!)&userLastName=\(userLastName!)&userPassword=\(userPassword!)"
        
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
                                let myAlert = UIAlertController(title: "Alert", message: "Registration successful", preferredStyle: UIAlertControllerStyle.Alert);
                                
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                                {(action) in
                                   
                                    self.dismissViewControllerAnimated(true,completion: nil)
                                    self.performSegueWithIdentifier("registerseague", sender: nil)
                                }
                                
                                myAlert.addAction(okAction);
                                self.presentViewController(myAlert, animated: true,completion:nil)
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
    self.presentViewController(myAlert, animated: true,completion:nil)
    
}
    
    @IBAction func cancel(button: UIBarButtonItem)
    {
        
        let smallFrame = CGRectInset(view.frame, view.frame.size.width / 4, view.frame.size.height / 4)
        let finalFrame = CGRectOffset(smallFrame, 0, view.frame.size.height)
        
        view.superview!.backgroundColor = UIColor.whiteColor()
        UIView.animateKeyframesWithDuration(4, delay: 0, options: .CalculationModeCubic, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5) {
                self.view.frame = smallFrame
            }
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5) {
                self.view.frame = finalFrame
            }
            }, completion:
            {
                animationFinished in
                self.navigationController?.popViewControllerAnimated(true)
        })
        }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        username.center.x -= self.view.bounds.width
        password.center.x -= self.view.bounds.width
        firstname.center.x -= self.view.bounds.width
        lastname.center.x -= self.view.bounds.width
        repeatpassword.center.x -= self.view.bounds.width
        signupButton.alpha = 0.0
        password.alpha=0.0
        username.alpha=0.0
        repeatpassword.alpha=0.0
        firstname.alpha=0.0
        lastname.alpha=0.0
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController!.navigationBarHidden = false
        self.navigationItem.title = "Sign Up"
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.0, delay: 0.3, options:.CurveEaseOut, animations: {
           
            self.username.alpha=1.0
            self.username.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: .CurveEaseOut, animations: {
             self.password.alpha=1.0
            self.password.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.6, options: .CurveEaseOut, animations: {
             self.repeatpassword.alpha=1.0
            self.repeatpassword.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.7, options: .CurveEaseOut, animations: {
             self.firstname.alpha=1.0
            self.firstname.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.8, options: .CurveEaseOut, animations: {
             self.lastname.alpha=1.0
            self.lastname.center.x += self.view.bounds.width
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.7, options: .CurveEaseOut, animations: {
            self.signupButton.alpha = 1.0
            }, completion:
            {
                animationFinished in
                        })
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