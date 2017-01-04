//
//  AppDelegate.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
   var timer: NSTimer?
  let healthManager:HealthManager = HealthManager()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
   // UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(10)
    let settings = UIUserNotificationSettings(forTypes:.Alert, categories: nil)
    application.registerUserNotificationSettings(settings)
    
    //healthManager.startHRObservingChanges()
    //healthManager.startBPObservingChanges()
    //healthManager.startPXObservingChanges()
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    // timer = NSTimer.scheduledTimerWithTimeInterval(5/1, target: self, selector: "ResignActive:", userInfo: nil, repeats: true)
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
   
    
  }
  /*func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
      test()
    completionHandler(.NewData)
  }
  
  func test()
  {
   print("didenterbackground")
    fetch {self.readOnTimer()}
  }
  
  func fetch(completion: ()-> Void) {
     completion()
  } */
    func readOnTimer()
  {
    
    
   // healthManager.readSampleByBloodPressure("https://iot-send-apns.mybluemix.net/bloodpressure")
    healthManager.readOxygen("https://iot-send-apns.mybluemix.net/pulseox")
    healthManager.readSampleHeartRate("https://iot-send-apns.mybluemix.net/heartrate")
    //enable stopTimer

    
    print("read here")
  }

  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // timer = NSTimer.scheduledTimerWithTimeInterval(5/1, target: self, selector: "testfore:", userInfo: nil, repeats: true)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
  
}

