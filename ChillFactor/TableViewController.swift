//
//  TableViewController.swift
//  ChillFactor
//
//  Created by Daniil Tarakanov on 20/08/2016.
//  Copyright © 2016 Daniil Tarakanov. All rights reserved.
//

import UIKit
import HealthKit
import CoreLocation
import Alamofire

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let healthManager:HealthManager = HealthManager()
    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    
    let kUnknownString   = "Unknown"
    var heartRate:HKQuantitySample?
    
    var timerMain = NSTimer()
    var timerNotRunning = true
    
    func authorizeHealthKit()
    {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
            self.startLocation()
        }
    }
    
    func startLocation()
    {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func startTimer()
    {
        timerMain = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(TableViewController.updateHR), userInfo: nil, repeats: true)
    }
    
    func uploadJSON(heartRate: Int, heartTime: String) {
        // Serialise and POST arrays
        let param = [
            "heartRate": heartRate,
            "heartTime": heartTime,
            "latitude": locValue.latitude,
            "longitude": locValue.longitude
        ]
        
        // Prepare request
        let request = NSMutableURLRequest(URL: NSURL(string: "https://atmosphere-5b99c.firebaseio.com/message_list.json")!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode parameters to JSON
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(param, options: [])
        request.HTTPBody = jsonData
        
        // POST the data to server
        Alamofire.request(request)
    }
    
    func updateHR()
    {
        // 1. Construct an HKSampleType for Heart Rate
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        // 2. Call the method to read the most recent Height sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHR, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading heart rate from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var hrDateString = self.kUnknownString
            self.heartRate = mostRecentHR as? HKQuantitySample;
            
            // 3. Format the heart rate to display it on the screen
            let heartRateUnit = HKUnit(fromString: "count/min")
            let value = self.heartRate?.quantity.doubleValueForUnit(heartRateUnit)
            
            // Get date
            let date = self.heartRate?.startDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            hrDateString = dateFormatter.stringFromDate(date!)
            
            
            // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
            self.uploadJSON(Int(value!), heartTime: hrDateString)
        })
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        authorizeHealthKit()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
        
        if timerNotRunning {
            timerNotRunning = false
            // Start the timer to upload data
            self.startTimer()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
