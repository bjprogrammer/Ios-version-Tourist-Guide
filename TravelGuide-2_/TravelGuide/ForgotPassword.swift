//
//  ForgotPassword.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/24/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//


import UIKit


class ForgotPassword:  UIViewController
{
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    override func viewDidLoad() {
      super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
       
        self.navigationItem.title = "Forgot Password"
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    
    @IBAction func sendButtonTapped(button: UIButton) {
        let userEmailAddress = emailAddressTextField.text
        
        if(userEmailAddress!.isEmpty)
        {
            let bounds = button.bounds
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options:[], animations: {
                button.bounds = CGRect(x: bounds.origin.x - 10, y: bounds.origin.y, width: bounds.size.width + 15, height: bounds.size.height)
                }, completion:
                {
                    animationFinished in
                    button.bounds = CGRect(x: bounds.origin.x , y: bounds.origin.y, width: bounds.size.width , height: bounds.size.height)
            })
            return
        }
        
        if(!isValidEmail(userEmailAddress!))
        {
            displayAlertMessage("Invalid email address")
            return
        }
        
        
        emailAddressTextField.resignFirstResponder()
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.dimBackground = true
        spinningActivity.animationType = MBProgressHUDAnimation.Fade
        spinningActivity.label.text = "Loading"
        spinningActivity.detailsLabel.text = "Please wait"
        
        
        let myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/requestNewPassword.php")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        let postString = "userEmail=\(userEmailAddress!)"
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
                        let userEmail = parseJSON["userEmail"] as? String
                        
                        if( userEmail != nil)
                        {
                            let myAlert = UIAlertController(title: "Alert", message: "We have sent you email message. Please check your Inbox.", preferredStyle: .Alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                            {
                                UIAlertAction in
                                self.dismissViewControllerAnimated(true, completion: nil)
                                for controller in self.navigationController!.viewControllers as Array
                                {
                                    if controller.isKindOfClass(ForgotPassword)
                                    {
                                        controller.navigationController?.popViewControllerAnimated(true)
                                    }
                                }
                            }
                            myAlert.addAction(okAction)
                            

                            self.presentViewController(myAlert, animated: true, completion: nil)
                            
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
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func userTappedBackground(gestureRecognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
}