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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    let basicCellIdentifier = "BasicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("hi")
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var locations = [CLLocation]()
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    override func viewWillAppear(animated: Bool) {
        NSLog("about to appear")
        if CLLocationManager.locationServicesEnabled() {
            NSLog("location services on")
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.appendContentsOf(locations)
        for loc in locations {
            NSLog("New location is %@", loc)
            self.tableView.reloadData()
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


