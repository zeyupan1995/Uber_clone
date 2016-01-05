//
//  RiderViewController.swift
//  Uber_Clone
//
//  Created by Apple on 1/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RiderViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate
{
    
    var locationManager: CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0

    var riderRequestActive = false
    
    @IBOutlet var map: MKMapView!
    
    
    @IBOutlet var callUberButton: UIButton!
    
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
            
            let riderRequest = PFObject(className:"riderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            riderRequest.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                    
                    self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
                    
                    
                } else {
                    // There was a problem, check error.description
                    
                    let alert = UIAlertController(title: "Cound not call Uber", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            }
            
            riderRequestActive = true
            
        } else {
            
            
            self.callUberButton.setTitle("Call an Uber", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            let query = PFQuery(className:"riderRequest")
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects {
                        for object in objects {
                            
                            object.deleteInBackground()
                        }
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        

        var query = PFQuery(className:"driverLocation")

        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)

        
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    
                    if objects.count > 0 {
                        
                        for object in objects {
                            self.callUberButton.setTitle("Driver is on the way", forState: UIControlState.Normal)

                        }
                    }
                }
            }
        
        
        }
        print("locations = \(location.latitude) \(location.longitude)")

        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Your location"
        self.map.removeAnnotations(map.annotations)
        self.map.addAnnotation(objectAnnotation)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
            
            locationManager.stopUpdatingLocation()
            
            PFUser.logOut()
            
        } 
    }
}
