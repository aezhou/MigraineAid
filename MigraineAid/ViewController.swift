//
//  ViewController.swift
//  MigraineAid
//
//  Created by Amanda Zhou on 11/10/15.
//  Copyright © 2015 Amanda Zhou. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Parse

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    let basicCellIdentifier = "BasicCell"

    
    var locations = [CLLocation]()
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(loginVC, animated: false, completion: nil)
            })
        } else {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startMonitoringSignificantLocationChanges()
            }
        }
    }
    
    @IBAction func signOutTapped(sender: UIButton) {
        // Send a request to log out a user
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.appendContentsOf(locations)
        for loc in locations {
            self.tableView.reloadData()
            let locationObject = PFObject(className: "LocationObject")
            locationObject["user"] = PFUser.currentUser()
            locationObject["timestamp"] = loc.timestamp
            locationObject["geopoint"] = PFGeoPoint(location: loc)
//            locationObject["longitude"] = loc.coordinate.latitude
//            locationObject["latitude"] = loc.coordinate.longitude
            locationObject["horizontal_accuracy"] = loc.horizontalAccuracy
            locationObject["course"] = loc.course
            locationObject["speed"] = loc.speed
            
//            locationObject.saveInBackgroundWithBlock {
//                (success: Bool, error: NSError?) -> Void in
//                if (success) {
//                    // successful!
//                } else {
//                    //there was an error... deal with types of errors
//                }
//                
//            }
            locationObject.saveEventually()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location manager failed with error: %@", error)
        if error.domain == kCLErrorDomain && CLError(rawValue: error.code) == CLError.Denied {
            //user denied location services so stop updating manager
            manager.stopUpdatingLocation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as! BasicCell
        cell.timeLabel.text = String(format: "%@", arguments: [locations[indexPath.row].timestamp])
        cell.locationlabel.text = String(format: "%.4f, %.4f", arguments: [locations[indexPath.row].coordinate.latitude, locations[indexPath.row].coordinate.longitude])
        return cell
    }
    
}


