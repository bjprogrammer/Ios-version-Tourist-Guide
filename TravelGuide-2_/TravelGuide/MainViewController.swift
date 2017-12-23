//
//  MainViewController.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/25/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class MainViewController:UIappViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate{
    var places = [Place]()
    var placesStore = PlacesStore()
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var type:String?
    var imageStore: ImageStore!
    let userId:String? = NSUserDefaults.standardUserDefaults().stringForKey( "userId")
    let locationManager = CLLocationManager()
    var timer = NSTimer()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    var state:String?
    var country:String?
    var city:String?
    var zipcode:String?
    @IBOutlet var location:UITextField?
    var placeid:String?
    var types = Array<String>()
    var rating:Float?
    var name:String?
    var viewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    @IBOutlet var customview: UIView?
    var myVC:connect?
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    
        myVC=storyboard?.instantiateViewControllerWithIdentifier("connectid") as? connect
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        
        //tableView.rowHeight = 150
        tableView.estimatedRowHeight = 75
        
        viewController = GMSAutocompleteResultsViewController()
        viewController!.delegate = self
        
        searchController = UISearchController(searchResultsController: viewController)
        searchController?.searchResultsUpdater = viewController
        
        // let cellReuseIdentifier = "cell"
        // tableView.registerClass(PlacesCell.self, forCellReuseIdentifier:cellReuseIdentifier)
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
        
        searchController?.searchBar.placeholder="Search"
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        location!.leftView = UIImageView(image: UIImage(named: "Image-19"))
        location!.leftViewMode = UITextFieldViewMode.Always
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.dimBackground = true
        spinningActivity.animationType = MBProgressHUDAnimation.Fade
        spinningActivity.label.text = "Loading"
        spinningActivity.detailsLabel.text = "Please wait"
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        type = NSUserDefaults.standardUserDefaults().stringForKey("type")!
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.imageStore = appDelegate.imageStore
        if(type! == "normal")
        {
            let imageUrl = NSURL(string:"http://iosgroupmap15.x10host.com/profile-pictures/\(userId!)/user-profile.jpg")
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                 if let imageData =  NSData(contentsOfURL: imageUrl!)
                 {
                     dispatch_sync(dispatch_get_main_queue(),{
                     self.imageStore!.setImage(UIImage(data: imageData)!, forKey: self.userId!)
                     spinningActivity.hideAnimated(true)
                     });
                }
                
            })
        }
            
        else if(type! == "fb")
        {
            let imageUrl = NSURL(string:"http://iosgroupmap15.x10host.com/fbprofile-pictures/\(userId!)/user-profile.jpg")
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                print(NSData(contentsOfURL: imageUrl!))
                if let imageData =  NSData(contentsOfURL: imageUrl!)
                {
                    dispatch_sync(dispatch_get_main_queue(),{
                        self.imageStore!.setImage(UIImage(data: imageData)!, forKey: self.userId!)
                        spinningActivity.hideAnimated(true)
                    });
                }
                
            })
        }
        else
        {
            let imageUrl = NSURL(string:"http://iosgroupmap15.x10host.com/twprofile-pictures/\(userId!)/user-profile.jpg")
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                print(NSData(contentsOfURL: imageUrl!))
                if let imageData =  NSData(contentsOfURL: imageUrl!)
                {
                    dispatch_sync(dispatch_get_main_queue(),{
                        
                        self.imageStore!.setImage(UIImage(data: imageData)!, forKey: self.userId!)
                        spinningActivity.hideAnimated(true)
                    });
                }
                
            })
        }
        spinningActivity.hideAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func leftSideButtonTapped(sender: AnyObject) {
        appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] 
        long = userLocation.coordinate.longitude
        lat = userLocation.coordinate.latitude
        
        print(long!, lat!)
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if (placemarks!.count > 0) {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func displayLocationInfo(placemark: CLPlacemark)
    {
            city=placemark.locality
            zipcode=placemark.postalCode
            state=placemark.administrativeArea
            country=placemark.country
        
        if let city=city,country=country,state=state,zipcode=zipcode
        {
            location?.text=city + "(" + state + ")" + "," + country + "-" + zipcode
            get_data_from_url("https://maps.googleapis.com/maps/api/place/search/json?location=\(lat!),\(long!)&types=restaurants&sensor=true&radius=5000&key=AIzaSyC_PFED4L7SCI58EMsIQxm6YcmdKgtFmFY")
            locationManager.stopUpdatingLocation()
        
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    //Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("cellForRowAtIndexPath: S: \(indexPath.section) R: \(indexPath.row)")
        
        let place = places[indexPath.row]
        
        let cell:PlacesCell = tableView.dequeueReusableCellWithIdentifier("cell",forIndexPath: indexPath) as! PlacesCell
        print(cell.ratingLabel)
        cell.nameLabel.text = place.name
        cell.ratingLabel.text = "\(place.rating)"
        
        if let rating = place.rating{
            
            let ratingDouble = rating as Double
            
            cell.ratingLabel.text = "\(ratingDouble)"
            if (ratingDouble >= 4.0) {
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
        }else{
            cell.openNowLabel.textColor = UIColor.redColor()
            cell.openNowLabel.text = "Closed"
        }
    
        if let types = place.types{
            var typeString = ""
            var i=0
            for type in types{
                i=i+1
                typeString.appendContentsOf("\(type), ")
                if(i == 3)
                {
                  break
                }
                
            }
            cell.typeLabel.textColor = UIColor.darkGrayColor()
            cell.typeLabel.text = typeString
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            cell.imageView?.image = place.icon
            cell.imageView?.setNeedsDisplay()
            cell.imageView?.layer.borderWidth = 1.5
            cell.imageView?.layer.borderColor = UIColor.grayColor().CGColor
            cell.imageView?.setNeedsLayout()
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.updateLabels()
        }
        
        return cell
    }
    
    func get_data_from_url(url:String)
    {
        let timeout = 15.0
        let url = NSURL(string: url)
        print(url)
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
                    typesArray.shuffle()
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = places[indexPath.row]
        self.placeid = place.placeID
        self.rating = place.rating as? Float
        self.types = place.types!
        self.name = place.name
        
        self.performSegueWithIdentifier("connect", sender: MainViewController.self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        let destinationVC = segue.destinationViewController as! connect
        destinationVC.placeid=placeid
        destinationVC.rating=rating
        destinationVC.name=name
        destinationVC.types=types
    }
}

 extension MainViewController: GMSAutocompleteResultsViewControllerDelegate
{
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        self.placeid = place.placeID
        self.rating = place.rating
        self.types = place.types
        self.name = place.name
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didSelectPrediction prediction: GMSAutocompletePrediction) -> Bool {
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("connect", sender: MainViewController.self)
        })
        return true
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: NSError) {
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}

extension Array
{
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}