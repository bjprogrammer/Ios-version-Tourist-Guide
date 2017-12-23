//
//  updateprofile.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/29/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class updateprofile: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet var firstname:UITextField?
    @IBOutlet var lastname:UITextField?
    @IBOutlet var email:UITextField?
    @IBOutlet var changepic:UILabel?
    @IBOutlet var pic:UIImageView?
    let userId:String = NSUserDefaults.standardUserDefaults().stringForKey( "userId")!
    let myImagePicker = UIImagePickerController()
    var imageStore: ImageStore!
    var type:String = NSUserDefaults.standardUserDefaults().stringForKey("type")!
    var spinningActivity:MBProgressHUD?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController!.navigationBarHidden = false
        self.navigationItem.title = "Update Profile"
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(updateprofile.tapFunction))
        changepic!.userInteractionEnabled = true
        changepic!.addGestureRecognizer(tap)
        
        firstname?.text = NSUserDefaults.standardUserDefaults().stringForKey("userFirstName")!
        lastname?.text = NSUserDefaults.standardUserDefaults().stringForKey("userLastName")!
        email?.text = NSUserDefaults.standardUserDefaults().stringForKey("userEmail")!
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.imageStore = appDelegate.imageStore
        
        myImagePicker.delegate = self
      
        pic!.contentMode=UIViewContentMode.ScaleAspectFit
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(imageStore)
        if(imageStore!.imageForKey(userId) != nil)
        {
            pic!.image = imageStore!.imageForKey(userId)
        }
    }
    
    @IBAction func leftSideButtonTapped(sender: AnyObject)
    {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    @IBAction func tapFunction(sender:UITapGestureRecognizer)
    {
        print("tap working")
        myImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myImagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])    {
        pic!.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.imageStore!.setImage((self.pic!.image)!, forKey: self.userId)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity!.dimBackground = true
        spinningActivity!.animationType = MBProgressHUDAnimation.Fade
        spinningActivity!.label.text = "Loading"
        spinningActivity!.detailsLabel.text = "Please wait"
        
        myImageUploadRequest()
    }
    
    
    func myImageUploadRequest()
    {
        var myUrl:NSURL?
        if(type=="normal")
        {
           myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/imageUpload.php")
        }
        else if(type=="fb")
        {
             myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/fbimageUpload.php")
        }
        else
        {
            myUrl = NSURL(string: "http://iosgroupmap15.x10host.com/scripts/twimageUpload.php")
        }

        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        
        
        let param = [
            "userId" : userId
        ]
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(pic!.image!, 1)
        
        if(imageData == nil)
        {
            return
        }
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            dispatch_sync(dispatch_get_main_queue(),{
                    self.spinningActivity?.hideAnimated(true)
            });
            
            if error != nil {
                print(error)
                return
            }
            
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary
                
                dispatch_sync(dispatch_get_main_queue(),{
                        
                        if let parseJSON = json
                        {
                            let userMessage = parseJSON["message"] as? String
                            self.displayAlertMessage(userMessage!)
                        }
                        else
                        {
                            // Display an alert message
                            let userMessage = "Could not upload image at this time"
                            self.displayAlertMessage(userMessage)
                        }
                });
            }
            catch
            {
                print(error)
            }
            
        }
        task.resume()
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil
        {
            for (key, value) in parameters!
            {
                body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageDataKey)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return body as NSData
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().UUIDString)"
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
}

extension NSMutableData
{
    
    func appendString(string: String)
    {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}