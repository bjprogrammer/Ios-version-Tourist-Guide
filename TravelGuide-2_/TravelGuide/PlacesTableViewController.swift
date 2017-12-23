//
//  PlacesTableViewController.swift
//  Photorama
//
//  Created by Ashish Singh on 01/05/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController{
    var places = [Place]()
    var placesStore = PlacesStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        get_data_from_url("https://maps.googleapis.com/maps/api/place/search/json?location=41.104805,29.024291&types=restaurant|cafe|meal_takeaway|meal_delivery|lodging|bar|night_club&sensor=true&radius=5000&key=AIzaSyBYaqSGmC3COwWS7DKZYd8cO21yY5pKUUU")
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        
        //tableView.rowHeight = 150
        tableView.estimatedRowHeight = 75
        
        print("Font: \(UIApplication.sharedApplication().preferredContentSizeCategory)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("PlacesViewController viewWillAppear")
        
        //reloadData() reloads the cells of the tableView
        placesStore.fetchEstablishments(completion: {(photosResult) -> Void in
            switch photosResult {
            case .Success(let photosArray):
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.reloadData()

                }
                
            case .Failure(let error):
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.reloadData()

                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    //Asks the data source for a cell to insert in a particular location of the table view.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("cellForRowAtIndexPath: S: \(indexPath.section) R: \(indexPath.row)")
        
        let place = places[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell", forIndexPath: indexPath) as! PlacesCell
        
        cell.nameLabel.text = place.name
        cell.ratingLabel.text = "\(place.rating)"
        
        if let rating = place.rating{
            
            let ratingDouble = rating as Double
            
            cell.ratingLabel.text = "\(ratingDouble)"
            if (ratingDouble > 4.0) {
                cell.ratingLabel.backgroundColor = UIColor.greenColor()
            }
            if (ratingDouble < 4.0) {
                cell.ratingLabel.backgroundColor = UIColor.orangeColor()
            }
            if (ratingDouble < 3.0){
                cell.ratingLabel.backgroundColor = UIColor.redColor()
            }
        }else{
            cell.ratingLabel.text = "N/A"
            cell.ratingLabel.backgroundColor = UIColor.grayColor()
        }
        
        if let open = place.openingHours{
            if open {
                cell.openNowLabel.textColor = UIColor.greenColor()
                cell.openNowLabel.text = "Open Now"
            }else{
                cell.openNowLabel.textColor = UIColor.redColor()
                cell.openNowLabel.text = "Closed"
            }
        }
        
        if let types = place.types{
            var typeString = ""
            for type in types{
                typeString.appendContentsOf("\(type), ")
            }
            //let subStrIdx = typeString.characters.count - 2
            //typeString = typeString.substringToIndex(subStrIdx)
            cell.typeLabel.text = typeString
        }
        
        let url = NSURL(string: place.iconString!)
        let data = NSData(contentsOfURL: url!)
        cell.imageView?.image = UIImage(data: data!)
        cell.imageView?.layer.borderWidth = 1.5
        cell.imageView?.layer.borderColor = UIColor.grayColor().CGColor
        
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.updateLabels()
        
        return cell
    }
    
    func get_data_from_url(url:String)
    {
        let timeout = 15.0
        let url = NSURL(string: url)
        let urlRequest = NSMutableURLRequest(URL: url!,
                                             cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData,
                                             timeoutInterval: timeout)
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(
            urlRequest,
            queue: queue,
            completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) in
                if data!.length > 0 && error == nil{
                    self.extract_json(data!)
                }else if data!.length == 0 && error == nil{
                    print("Nothing was downloaded")
                } else if error != nil{
                    print("Error happened = \(error)")
                }
            }
        )
    }
    
    func extract_json(jsonData:NSData)
    {
        do{
            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            var results = json!["results"] as! Array<NSDictionary>
            print(results.count)
            
            var iconString: String?
            var placeIdString: String?
            var nameString: String?
            var ratingNumber: NSNumber?
            var openNowVal: Bool?
            var typesArray = [String]()
            
            for i in 0..<results.count
            {
                if let iconarray = results[i]["icon"] as! String!
                {
                    iconString = iconarray
                }
                if let placearray = results[i]["place_id"] as! String!
                {
                    placeIdString = placearray
                }
                if let namearray = results[i]["name"] as! String!
                {
                    nameString = namearray
                }
                if let ratingarray = results[i]["rating"] as! NSNumber!
                {
                    ratingNumber = ratingarray
                }
                if let item = results[i]["opening_hours"] as! NSDictionary!
                {
                    if let opennow=item["open_now"] as! Bool!
                    {
                        openNowVal = opennow
                    }
                }
                if let types = results[i]["types"] as! NSArray!
                {
                    for type in types
                    {
                        typesArray.append(type as! String)
                    }
                }
                let newPlace = Place(name: nameString!, placeID: placeIdString!, openingHours: openNowVal, rating: ratingNumber, iconString:iconString, types: typesArray)
                
                places.append(newPlace)
                
            }
        }
            
        catch
        {
            print("Error with Json: \(error)")
        }
        do_table_refresh();
    }
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }
    
}
