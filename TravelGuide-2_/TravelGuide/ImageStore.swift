//
//  ImageStore.swift
//  Homeowner
//
//  Created by Swastik Brahma on 4/11/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class ImageStore {
    var cache = NSCache()
    
    //imageURLForKey returns the URL for an image for a given key
    //We will save every image to a separate file
    func imageURLForKey(key: String) -> NSURL {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent(key)
    }
    
    //Add a key-image pair to the cache AND save it on the disk
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key)
        
        let imageURL = imageURLForKey(key)
        
        //Creates an NSData instance (representing a JPEG image) and writes it to the given URL
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            data.writeToURL(imageURL, atomically: true)
        }
    }
    
    //Retrieve an image from the cache or disk for a given key.
    func imageForKey(key: String) -> UIImage? {
        if let imageFromCache = cache.objectForKey(key) as? UIImage {
            return imageFromCache
        }
        
        let imageURL = imageURLForKey(key)
        
        if let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) {
            cache.setObject(imageFromDisk, forKey: key) //Add the image to the cache
            return imageFromDisk
        }
        
        return nil
    }
    
    //Remove an image from the cache and the disk
    func removeImageForKey(key: String) {
        cache.removeObjectForKey(key)
        
        let imageURL = imageURLForKey(key)
        
        do {
             //removeItemAtURL() can throw an error
            try NSFileManager.defaultManager().removeItemAtURL(imageURL)
        }
        catch let deleteError {
            print("Error removing image: \(deleteError)")
        }
    }
}






