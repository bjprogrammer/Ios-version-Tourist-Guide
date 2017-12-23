//
//  GoogleApi.swift
//  Photorama
//
//  Created by Ashish Singh on 30/04/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit


enum PlacesResult {
    case Success([Place])
    case Failure(ErrorType)
}

enum GoogleError: ErrorType {
    case InvalidJSONData
}

struct GoogleApi {
    
    static var placeStore: PlacesStore = PlacesStore()
    
    private static let baseURLString = "https://maps.googleapis.com/maps/api/place/search/json"
    private static let APIKey = "AIzaSyBYaqSGmC3COwWS7DKZYd8cO21yY5pKUUU"
    
    private static func googleURL() -> NSURL {
        let components = NSURLComponents(string: baseURLString)
        
        var queryItems = [NSURLQueryItem]()
        
        let baseParams = ["location": "41.104805,29.024291",
                          "radius": "5000",
                          "sensor": "true",
                          "key": APIKey,
                          "types": "restaurant|cafe|meal_takeaway|meal_delivery|lodging|bar|night_club"]
        
        for (key, value) in baseParams {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        
        components?.queryItems = queryItems
        
        return components!.URL!
    }
    
    static func getPlacesURL() -> NSURL {
        return googleURL()
    }
    
    static func placesFromJSONData(placeid : String, instance : connect)-> PlacesResult
    {
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&key=AIzaSyC_PFED4L7SCI58EMsIQxm6YcmdKgtFmFY")
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if let results = json["result"] as! NSDictionary!
                    {
                        if let item = results["opening_hours"] as! NSDictionary!
                        {
                            if let opennow=item["open_now"] as! Bool!
                            {
                                if opennow {
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        instance.openNowLabel.textColor = UIColor.greenColor()
                                        instance.openNowLabel.text = "Open Now"
                                    }
                                }
                                else
                                {
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        instance.openNowLabel.textColor = UIColor.redColor()
                                        instance.openNowLabel.text = "Closed"
                                    }
                                }
                            }
                        }
                        else
                        {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                instance.openNowLabel.textColor = UIColor.redColor()
                                instance.openNowLabel.text = "Closed"
                            }
                        }
                        
                        if let placeName = results["name"]
                        {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                instance.nameLabel.text = placeName as? String
                            }
                        }
                        
                        if let placeRating = results["rating"]
                        {
                            let ratingDouble = placeRating as! Double
                            instance.ratingLabel.text = "\(ratingDouble)"
                            if (ratingDouble >= 4.0) {
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    instance.ratingLabel.backgroundColor = UIColor.greenColor()
                                }
                            }
                            if (ratingDouble < 4.0) {
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    instance.ratingLabel.backgroundColor = UIColor.orangeColor()
                                }
                            }
                            if (ratingDouble < 3.0){
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    instance.ratingLabel.backgroundColor = UIColor.redColor()
                                }
                            }
                        }
                        else
                        {
                            NSOperationQueue.mainQueue().addOperationWithBlock
                            {
                                instance.ratingLabel.text = "N/A"
                                instance.ratingLabel.backgroundColor = UIColor.grayColor()
                            }
                        }
                        
                        if let item2 = results["reviews"] as! NSArray!
                        {
                            var j = 0
                            for i in item2
                            {
                                let reviewer = i as! NSDictionary
                                instance.authorname.insert((reviewer["author_name"] as! NSString), atIndex: j)
                                instance.text.insert((reviewer["text"] as! NSString), atIndex: j)
                                instance.relativedescription.insert((reviewer["relative_time_description"] as! NSString), atIndex: j)
                                 j=j+1
                            }
                        }
                        for i in 0..<instance.authorname.endIndex
                        {
                            print("\(instance.authorname[i]) Reviewed at time: \(instance.relativedescription[i])")
                            print("Review: \(instance.text[i])")
                        }
                        
                        if let photos = results["photos"] as! NSArray!
                        {
                            let firstPhoto = photos.firstObject as! NSDictionary!
                            let photoReference = firstPhoto["photo_reference"]
                            
                            let imageURL = NSURL.init(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference!)&key=AIzaSyC_PFED4L7SCI58EMsIQxm6YcmdKgtFmFY")
                            
                            if let imageData = NSData(contentsOfURL: imageURL!)
                            {
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    let uiImage = UIImage(data: imageData)
                                    let size = uiImage!.size
                                    
                                    let widthRatio  = 350  / uiImage!.size.width
                                    let heightRatio = 225 / uiImage!.size.height
                                    
                                    var newSize: CGSize
                                    if(widthRatio > heightRatio) {
                                        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
                                    } else {
                                        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
                                    }
                                    
                                    if(newSize.width != 350)
                                    {
                                        newSize.width=350
                                    }
                                    if(newSize.height != 225)
                                    {
                                        newSize.height=225
                                    }
                                    
                                    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
                                    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                                    uiImage!.drawInRect(rect)
                                    let newImage = UIGraphicsGetImageFromCurrentImageContext()
                                    UIGraphicsEndImageContext()
                                    instance.mainImage.image = newImage
                                    instance.mainImage?.setNeedsDisplay()
                                    instance.mainImage?.layer.borderWidth = 1.5
                                    instance.mainImage?.layer.borderColor = UIColor.grayColor().CGColor
                                    instance.mainImage?.setNeedsLayout()
                                }
                            }
                        }
                        if let addressComponent = results["vicinity"]{
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                instance.addressLabel.text = addressComponent as? String
                            }
                        }
                        
                        if let phoneNumber = results["international_phone_number"]
                        {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                instance.phoneLabel.text = phoneNumber as? String
                            }
                        }
                    }
                }
                    
                catch
                {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    
    return .Failure(GoogleError.InvalidJSONData)
 }
}