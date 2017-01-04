//
//  MasterViewController.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation

import UIKit
import MessageUI
var StatusTxt: String = ""
class MasterViewController: UITableViewController {
  var timer: NSTimer?
  let kAuthorizeHealthKitSection = 0
  @IBOutlet weak var SendStatus: UILabel!
  //let kProfileSegueIdentifier = "profileSegue"
  //let kWorkoutSegueIdentifier = "workoutsSeque"
  //@IBOutlet var StopTimerLabel: UILabel!
  //@IBOutlet var activityIndicator: UIActivityIndicatorView!
  //var Boolauthorized: Bool = false
  let healthManager:HealthManager = HealthManager()
  override func viewDidLoad() {
    super.viewDidLoad()
    SendStatus.text = StatusTxt
    self.title = "Patient: John Doe"
    
  }
  
  
  func authorizeHealthKit()
  {
    //print("TODO: Request HealthKit authorization")
    healthManager.authorizeHealthKit { (authorized,  error) -> Void in
      if authorized {
        print("HealthKit authorization received.")
        self.showAlert("Authorized", message: "HealthKit authorization received")
        
        //self.Boolauthorized = true
        self.healthManager.startHRObservingChanges()
       // self.healthManager.startBPObservingChanges()
       // self.healthManager.startPXObservingChanges()


      }
      else
      {
        print("HealthKit authorization denied!")
        if error != nil {
          print("\(error)")
        }
      }
    }
  }
  
  
  // MARK: - Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    /*if segue.identifier ==  kProfileSegueIdentifier {
      
      if let profileViewController = segue.destinationViewController as? ProfileViewController {
        profileViewController.healthManager = healthManager
      }
    }
    else if segue.identifier == kWorkoutSegueIdentifier {
      if let workoutViewController = (segue.destinationViewController as! UINavigationController).topViewController as? WorkoutsTableViewController {
        workoutViewController.healthManager = healthManager;
      }
    }*/
  }
  func showAlert(title:String, message:String) {
    let alert = UIAlertController(title: title,
      message: message, preferredStyle: .Alert)
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil)
    alert.addAction(dismissAction)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - TableView Delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    switch (indexPath.section, indexPath.row)
    {
    case (kAuthorizeHealthKitSection,0):
      authorizeHealthKit()
   /* case(kAuthorizeHealthKitSection, 1):
     // healthManager.readSampleByBloodPressure("https://iot-send-apns.mybluemix.net/bloodpressure")
      timerSend()
      break
    case (kAuthorizeHealthKitSection, 2):
      
      healthManager.readSampleByBloodPressure("https://testrti.mybluemix.net/medical")
      break*/
    /*case(kAuthorizeHealthKitSection, 2):
      healthManager.readSampleByBloodPressure("https://iot-send-apns.mybluemix.net/bloodpressure")
      healthManager.readOxygen("https://iot-send-apns.mybluemix.net/pulseox")
      healthManager.readSampleHeartRate("https://iot-send-apns.mybluemix.net/heartrate")
    case (kAuthorizeHealthKitSection, 3):
      stopTimer()
      break */
    default:
      break
    }
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  
  
 /* func timerSend()
  {
    StopTimerLabel.enabled = true
    activityIndicator.startAnimating()
    timer = NSTimer.scheduledTimerWithTimeInterval(5/1, target: self, selector: "readOnTimer:", userInfo: nil, repeats: true)
    
  }
  func readOnTimer(timer: NSTimer)
  {
    
    
    healthManager.readSampleByBloodPressure("https://iot-send-apns.mybluemix.net/bloodpressure")
    healthManager.readOxygen("https://iot-send-apns.mybluemix.net/pulseox")
    healthManager.readSampleHeartRate("https://iot-send-apns.mybluemix.net/heartrate")
    //enable stopTimer
    
    
    //print("read here")
  }
  func stopTimer()
  {
    timer!.invalidate()
    //disableTimer
    activityIndicator.stopAnimating()
    StopTimerLabel.enabled =  false
  }*/
  
}
