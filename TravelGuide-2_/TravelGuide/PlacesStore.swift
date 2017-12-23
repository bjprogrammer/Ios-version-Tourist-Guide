//
//  PlacesStore.swift
//  Photorama
//
//  Created by Ashish Singh on 01/05/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class PlacesStore{
    var allPlaces = [Place]()
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    init(){
        //initializing default item and adding it to data source
    }
    
    func fetchEstablishments(completion completion: (PlacesResult) -> Void){
        let googleUrl = GoogleApi.getPlacesURL()
        
        print(googleUrl)
        let googleRequest = NSURLRequest(URL: googleUrl)
        
        let googleTask =  session.dataTaskWithRequest(googleRequest, completionHandler: {(data, response, error) -> Void in
            //code for processing
            let result = self.processEstablishmentRequest(data, error: error)
            completion(result)
            
        })
        googleTask.resume()
    }
    
    func processEstablishmentRequest(data: NSData?, error: NSError?) -> PlacesResult {
        if data != nil {
            return GoogleApi.placesFromJSONData((data?.description)!, instance: connect())
        }
        else {
            //print("Error downloading data: \(error!)")
            return .Failure(error!)
        }
    }
}
