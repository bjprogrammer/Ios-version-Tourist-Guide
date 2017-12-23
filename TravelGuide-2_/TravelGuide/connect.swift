//
//  connect.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 5/1/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit
import GooglePlaces

class connect: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var openNowLabel: UILabel!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    var placeid:String?
    var opennow:Bool?
    var name:String?
    var rating: Float?
    var types = Array<String>()
    var authorname = Array<NSString>()
    var text = Array<NSString>()
    var relativedescription = Array<NSString>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid!)&key=AIzaSyC_PFED4L7SCI58EMsIQxm6YcmdKgtFmFY")
        
        //JSONParsing
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("file downloaded successfully.")
                
                do{
                    // print(data!)
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    //print(json)
                    if let results = json["result"] as! NSDictionary!
                    {
                        //print(results)
                        if let item = results["opening_hours"] as! NSDictionary!
                        {
                            if let opennow=item["open_now"] as! Bool!
                            {
                                self.opennow=opennow
                            }
                        }
                        if let item2 = results["reviews"] as! NSArray!
                        {
                            //print(item2)
                            var j = -1
                            for i in item2
                            {
                                let reviewer = i as! NSDictionary
                                //print(reviewer)
                                j=j+1
                                
                                self.authorname+=[reviewer["author_name"] as! NSString]
                                
                                self.text+=[reviewer["text"] as! NSString]
                                self.relativedescription+=[reviewer["relative_time_description"] as! NSString]
                                //print(post)
                                // print((authorname as String)+"-"+(text as String))
                            }
                        }
                    }
                }
                    
                catch
                {
                    print("Error with Json: \(error)")
                }
                GoogleApi.placesFromJSONData(self.placeid!,instance: self)
            }
        }
        
        task.resume()
    }
    
    }