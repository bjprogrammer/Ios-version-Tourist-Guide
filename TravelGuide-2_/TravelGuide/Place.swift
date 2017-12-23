//
//  Place.swift
//  Photorama
//
//  Created by Ashish Singh on 30/04/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class Place {
    let name: String
    let placeID: String
    let openingHours: Bool?
    let rating: NSNumber?
    let iconString: String?
    let types: [String]?
    var icon: UIImage?
    
    init(name: String, placeID: String, openingHours: Bool?, rating: NSNumber?, iconString:String?, types: [String]?) {
        self.name = name
        self.placeID = placeID
        self.openingHours = openingHours
        self.rating = rating
        self.iconString = iconString
        self.types = types
        
        dispatch_async(dispatch_get_main_queue(), {
            GMSPlacesClient.sharedClient().lookUpPhotosForPlaceID(self.placeID) { (photos, error) -> Void in
                if let error = error {
                    // TODO: handle the error.
                    print("Error: \(error.localizedDescription)")
                } else {
                    if let firstPhoto = photos?.results.first {
                        GMSPlacesClient.sharedClient().loadPlacePhoto(firstPhoto, callback: {
                            (photo, error) -> Void in
                            if let error = error {
                                // TODO: handle the error.
                                print("Error: \(error.localizedDescription)")
                            } else {
                                
                                    
                                    self.icon = self.resizeImage(photo!, targetSize: CGSizeMake(80, 75))
                                
                            }
                        })
                    }
                }
            }
        
        })

      
        
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
    newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        
    } else {
    newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
        if(newSize.width != 80)
        {
            newSize.width=80
        }
        if(newSize.height != 75)
        {
            newSize.height=75
        }
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
        // newImage=UIImage(named: "Image-18")
        
    return newImage
    }

}
