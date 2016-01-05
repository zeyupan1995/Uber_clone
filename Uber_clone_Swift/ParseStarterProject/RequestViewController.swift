//
//  RequestViewController.swift
//  Uber_Clone
//
//  Created by Apple on 1/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController,CLLocationManagerDelegate {

    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername:String = ""
    
    @IBOutlet var map: MKMapView!
    
    
    @IBAction func pickUpRider(sender: AnyObject) {
    
        let query = PFQuery(className:"riderRequest")
        query.whereKey("username", equalTo: requestUsername)
//        query.limit = 10
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    
                    for object in objects {
                        
                        var query = PFQuery(className:"riderRequest")
                        query.getObjectInBackgroundWithId(object.objectId!) {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil {
                                print(error)
                            } else if let object = object{
                                
                                object["driverResponded"] = PFUser.currentUser()!.username!
                                object.saveInBackground()
                                
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                
                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) -> Void in
                                    
                                    if error != nil {
                                        
                                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                                
                                    } else {
                                        
                                        if placemarks!.count > 0 {
                                            
                                            let pm = placemarks![0] as! CLPlacemark
                                            
                                            let mkPm = MKPlacemark(placemark: pm)
                                            var mapItem = MKMapItem(placemark: mkPm)
                                            
                                            mapItem.name = "The way I want to go"

                                            var launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                            
                                            mapItem.openInMapsWithLaunchOptions(launchOptions)

                                        }
                                        else {
                                            print("Problem with the data received from geocoder")
                                        }
                                    }
                                    
                                    
                                })
                                
                            }
                        }
                    
                    
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

        
    }
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(requestLocation.latitude, requestLocation.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        map.removeAnnotations(map.annotations)
        self.map.addAnnotation(objectAnnotation)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
