//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class HealthManager {
  
  let healthKitStore: HKHealthStore = HKHealthStore()
  let patientName: String = "John Doe"
  var lastTimeStamp_BP: NSDate = NSDate.distantPast()
  var lastTimeStamp_HR: NSDate = NSDate.distantPast()
  var lastTimeStamp_OX: NSDate = NSDate.distantPast()
  var lastTimeStamp_weight: NSDate = NSDate.distantPast()
  //let RecentTimeStampe
 
  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
  {
    // 1. Set the types you want to read from HK Store
    let healthKitTypesToRead = Set(arrayLiteral:
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
    HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
    //  HKObjectType.quantityTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)!,
     // HKQuantityType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierOxygenSaturation)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
      HKObjectType.workoutType()
      )
    
    // 2. Set the types you want to write to HK Store
    let healthKitTypesToWrite = Set(arrayLiteral:
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
      HKQuantityType.workoutType()
      
      )
    
    // 3. If the store is not available (for instance, iPad) return an error and don't go on.
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: "com.gsc.ind.giot", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil )
      {
        completion(success:false, error:error)
      }
      return;
    }
    
    // 4.  Request HealthKit authorization
    healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
      
      if( completion != nil )
      {
        completion(success:success,error:error)
      }
    }
  }
  
  func readProfile() -> (age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
  {
    //var error:NSError?
    var age:Int?
    
    // 1. Request birthday and calculate age
    var birthDay: NSDate
    do {
    birthDay = try healthKitStore.dateOfBirth()
    
      let today = NSDate()
      //let _calendar = NSCalendar.currentCalendar()
      let differenceComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions(rawValue: 0) )
      age = differenceComponents.year
    }
    catch let error as NSError{
      print("Error reading Birthday: \(error)")
    }
    
    // 2. Read biological sex
    var biologicalSex:HKBiologicalSexObject?
    do {
      
    biologicalSex = try healthKitStore.biologicalSex()
    }
    catch let error as NSError{
      print("Error reading Biological Sex: \(error)")
    }
    
    // 3. Read blood type
    var bloodType:HKBloodTypeObject?
    do{
  
      bloodType = try healthKitStore.bloodType()
    }
    catch let error as NSError {
      print("Error reading Blood Type: \(error)")
    }
    // 4. Return the information read in a tuple
    return (age, biologicalSex, bloodType)
  }
  func auth()
  {
    //print("TODO: Request HealthKit authorization")
    authorizeHealthKit { (authorized,  error) -> Void in
      if authorized {
        print("HealthKit authorization received.")
    
        
        //self.Boolauthorized = true
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
  
  
  func startHRObservingChanges()
  {
    //auth()
    let typeHeartRate = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    let query: HKObserverQuery = {[weak self] in
      let strongSelf = self!
      return HKObserverQuery(sampleType: typeHeartRate!,
        //predicate: strongSelf.longRunningPredicate,
        predicate : nil, //all samples delivered
        updateHandler: strongSelf.HRChangedHandler)
      }()
    
    
    healthKitStore.executeQuery(query)
    healthKitStore.enableBackgroundDeliveryForType(typeHeartRate!, frequency: .Immediate, withCompletion: {(succeeded: Bool, error: NSError?)-> Void in
      
      
      if succeeded{
        print("Enabled background delivery of changes")
      } else {
        if let theError = error{
          print("Failed to enable background delivery of changes. ")
          print("Error = \(theError)")
        }
      }})  
    
  }
  
  
  func HRChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError?)  {
    
    print("Got HR update ")
    
    //Here, I need to actually query for the changed values..
    //using the standard query functions in HealthKit..
           //Tell IOS we're done... updated my server, etc.
    let notification = UILocalNotification()
    notification.alertBody = "Changed HealthKit App"
    notification.alertAction = "open"
    notification.soundName = UILocalNotificationDefaultSoundName
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification) 
 
    
    //let heartrate = ["Patient": self.patientName];
    //send to Liping_new Tab in NodeRed
    readSampleHeartRate("https://medicaldevices-nr.mybluemix.net/api/v02/medicalDevice")
    readSampleByBloodPressure("https://medicaldevices-nr.mybluemix.net/api/v02/medicalDevice")
    readOxygen("https://medicaldevices-nr.mybluemix.net/api/v02/medicalDevice")
    readScale("https://medicaldevices-nr.mybluemix.net/api/v02/medicalDevice")
    
    completionHandler()
    
  }
  //Bloodpressure
  
  func startBPObservingChanges()
  {
    //auth()
    let systolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
    
    let query: HKObserverQuery = {[weak self] in
      let strongSelf = self!
      return HKObserverQuery(sampleType: systolicType!,
        //predicate: strongSelf.longRunningPredicate,
        predicate : nil, //all samples delivered
        updateHandler: strongSelf.BPChangedHandler)
      }()
    
    
    healthKitStore.executeQuery(query)
   /* healthKitStore.enableBackgroundDeliveryForType(systolicType!, frequency: .Immediate, withCompletion: {(succeeded: Bool, error: NSError?)-> Void in
      
      
      if succeeded{
        print("Enabled background delivery of changes")
      } else {
        if let theError = error{
          print("Failed to enable background delivery of changes. ")
          print("Error = \(theError)")
        }
      }})  */
    
  }
  
  func BPChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError?)  {
    
    print("Got BP update ")
    
    //Here, I need to actually query for the changed values..
    //using the standard query functions in HealthKit..
    //Tell IOS we're done... updated my server, etc.
    let notification = UILocalNotification()
    notification.alertBody = "Changed blood pressure in HealthKit App"
    notification.alertAction = "open"
    notification.soundName = UILocalNotificationDefaultSoundName
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
    
    
    //let heartrate = ["Patient": self.patientName];
    //send to Liping_new Tab in NodeRed
    readSampleByBloodPressure("http://medicaldevices-nr.mybluemix.net/medDeviceNew/bloodpressure")
   
    
    completionHandler()
    
  }
  //pusleox
  
  func startPXObservingChanges()
  {
   // auth()
   let typeOxygen = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierOxygenSaturation)
    let query: HKObserverQuery = {[weak self] in
      let strongSelf = self!
      return HKObserverQuery(sampleType: typeOxygen!,
        //predicate: strongSelf.longRunningPredicate,
        predicate : nil, //all samples delivered
        updateHandler: strongSelf.PXChangedHandler)
      }()
    
    
    healthKitStore.executeQuery(query)
    healthKitStore.enableBackgroundDeliveryForType(typeOxygen!, frequency: .Immediate, withCompletion: {(succeeded: Bool, error: NSError?)-> Void in
      
      
      if succeeded{
        print("Enabled background delivery of changes")
      } else {
        if let theError = error{
          print("Failed to enable background delivery of changes. ")
          print("Error = \(theError)")
        }
      }})
    
  }
  
  
  func PXChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError?)  {
    
    print("Got pulseox update ")
    
    //Here, I need to actually query for the changed values..
    //using the standard query functions in HealthKit..
    //Tell IOS we're done... updated my server, etc.
    let notification = UILocalNotification()
    notification.alertBody = "Changed pulse ox in HealthKit App"
    notification.alertAction = "open"
    notification.soundName = UILocalNotificationDefaultSoundName
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
    
    
    //let heartrate = ["Patient": self.patientName];
    //send to Liping_new Tab in NodeRed
    readOxygen("https://medicaldevices-nr.mybluemix.net/medDeviceNew/pulseox")
    
    
    completionHandler()
    
  }
  
  func readSample( sampleType:HKSampleType, completion: ((HKSample!, NSError!) -> Void)!)
  {
    
  //let typeOxygen = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierOxygenSaturation)
  let startDate = NSDate.distantPast()
  let endDate   = NSDate()
  let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
  
  let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
  let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 2, sortDescriptors: [sortDescriptor])
    { (sampleQuery, results, error ) -> Void in
      if let queryError = error {
        completion(nil,error)
        return;
      }
      
        // Get the first sample
        let mostRecentSample = results!.first as? HKQuantitySample
        if (completion != nil) {
        completion?(mostRecentSample,nil)
         }
    }
    self.healthKitStore.executeQuery(sampleQuery)
  
  }
  func readOxygen(url: String)
  {
    let typeOxygen = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierOxygenSaturation)
    var pulseox: [String: AnyObject] = [:]
    self.readSample(typeOxygen!, completion: {(valueOxygen,error)-> Void in
         let data = valueOxygen as? HKQuantitySample
          let dataOxygen = (data?.quantity.doubleValueForUnit(HKUnit.percentUnit()))!*100
          let DateStamp = data?.endDate
           print("Oxygen\(dataOxygen) ")

            if DateStamp!.compare(self.lastTimeStamp_OX) == NSComparisonResult.OrderedDescending
            {
              self.lastTimeStamp_OX = DateStamp!
            
             let dateFormatter:NSDateFormatter = NSDateFormatter()
             dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
             let DateInFormat:String = dateFormatter.stringFromDate(DateStamp!)
      
             pulseox = ["pulseox": dataOxygen, "dateStamp": DateInFormat, "deviceSerial": "po1000"];
              
             self.postString(pulseox, requestURL: url)
            }
    
    });
  }
   //Glucose is not functioning, there is a bug in iFora app. To work
  func readBloodGlucose(url: String){
    let type = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
    let startDate = NSDate.distantPast()
    let endDate = NSDate()
    let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    let sampleQuery = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in
        let mostRecentSample = results!.first as? HKQuantitySample
        let data = mostRecentSample!.quantity
        print("Glucose: \(data)")
        let endDate = mostRecentSample!.endDate
        let startDate = mostRecentSample!.startDate
        
        print("Dates: \(endDate) - \(startDate)")
        
    }
    self.healthKitStore.executeQuery(sampleQuery)
  }
  
  func readSampleHeartRate(url: String)
  {
    let typeHeartRate = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    var heartrate:[String: AnyObject] = [:]
    self.readSample(typeHeartRate!, completion: {(valueHeartRate,error)-> Void in
      let data = valueHeartRate as? HKQuantitySample
      let dataHeartRate = data?.quantity.doubleValueForUnit(HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit()))
      let DateStamp = data!.endDate
       print("HeartRate\(dataHeartRate) ")
      if DateStamp.compare(self.lastTimeStamp_HR) == NSComparisonResult.OrderedDescending
      {
        self.lastTimeStamp_HR = DateStamp
        let dateFormatter:NSDateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      let DateInFormat:String = dateFormatter.stringFromDate(DateStamp)
      
      heartrate = ["heartRate": dataHeartRate!,"dateStamp": DateInFormat,"deviceSerial": "hr1000"];
      self.postString(heartrate, requestURL: url)
        
      }
      
    });
  }
  
  func readSampleByBloodPressure(url: String)
  {
    //var bloodPressure: [String: String]
    guard let type = HKQuantityType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure),
      let systolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic),
      let diastolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic) else {
        // display error, etc...
        return
    }
    
    let startDate = NSDate.distantPast()
    let endDate   = NSDate()
    let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
    
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in
        
        if let dataLst = results as? [HKCorrelation] {
          for var index=0;index<dataLst.count;++index
          {
            if let data1 = dataLst[index].objectsForType(systolicType).first as? HKQuantitySample,
              let data2 = dataLst[index].objectsForType(diastolicType).first as? HKQuantitySample {
                
                let value1 = data1.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                let value2 = data2.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                let DateStamp1 = data2.startDate
                let DateStamp2 = data2.endDate
                print("\(value1) / \(value2)")
                print("\(DateStamp1) / \(DateStamp2)")
                if DateStamp2.compare(self.lastTimeStamp_BP) == NSComparisonResult.OrderedDescending
                {
                  self.lastTimeStamp_BP = DateStamp2
                  let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let DateInFormat:String = dateFormatter.stringFromDate(DateStamp2)

                
                
                let bloodPressure: [String: AnyObject] = ["diastolic": value2, "systolic": value1, "dateStamp": DateInFormat, "deviceSerial": "bp1000"];
                
                
              
                self.postString(bloodPressure, requestURL: url)
                }
              
              }
           }
          }
    }
    self.healthKitStore.executeQuery(sampleQuery)
  }
  
  func readScale(url: String)
  {
    let typeWeight = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    var weight: [String: AnyObject] = [:]
    self.readSample(typeWeight!, completion: {(valueWeight,error)-> Void in
      var weightLocalizedString: String
      let data = valueWeight as? HKQuantitySample
      if let kilograms = data?.quantity.doubleValueForUnit(HKUnit.poundUnit()) {
        let weightFormatter = NSMassFormatter()
        weightFormatter.forPersonMassUse = true;
        weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
      
      let DateStamp = data?.endDate
      print("Weight\(weightLocalizedString) ")
      
      if DateStamp!.compare(self.lastTimeStamp_weight) == NSComparisonResult.OrderedDescending
      {
        self.lastTimeStamp_weight = DateStamp!
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let DateInFormat:String = dateFormatter.stringFromDate(DateStamp!)
        
        weight = ["weight": kilograms, "dateStamp": DateInFormat, "deviceSerial": "s1000"];
        
        self.postString(weight, requestURL: url)
      }
      }
      
    });
  }
  
  func postString(jsonString: AnyObject, requestURL: String)
  {
    let request = NSMutableURLRequest(URL: NSURL(string: requestURL)!)
    
    request.HTTPMethod = "POST"
    //let postString = jsonString
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    var jsondata: NSData?
    do{
      jsondata = try NSJSONSerialization.dataWithJSONObject(jsonString,  options: [])
    }
    catch let error as NSError
    {
      print("Error reading blood pressure: \(error)")
    }

    request.HTTPBody = jsondata
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      
      if error != nil {
        print("error=\(error)")
        return
      }
      
      print("response = \(response)")
      
      let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
      let notification = UILocalNotification()
      notification.alertBody = "data Sent"
      notification.alertAction = "open"
      notification.soundName = UILocalNotificationDefaultSoundName
      StatusTxt = "datasent"
      UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    task.resume()
  }
  
 }