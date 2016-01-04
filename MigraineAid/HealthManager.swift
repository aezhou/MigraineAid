//
//  HealthManager.swift
//  MigraineAid
//
//  Created by Amanda Zhou on 11/22/15.
//  Copyright © 2015 Amanda Zhou. All rights reserved.
//

import Foundation
import HealthKit
import Parse

class HealthManager {
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    let stepCountIdentifier = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        let healthKitTypesToRead: Set = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!, HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!, HKObjectType.workoutType()]
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.aezhou.migrainAid", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        healthStore!.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success,error:error)
            }
        }
    }
    
    func observeStepQuantityType() {
        if let stepType = stepCountIdentifier,  healthStore = self.healthStore {
            print("observe step quantity type")
            
            let query: HKObserverQuery = HKObserverQuery(sampleType: stepType, predicate: nil, updateHandler: self.stepCountChangedHandler)
            
            healthStore.executeQuery(query)
            
            healthStore.enableBackgroundDeliveryForType(stepType, frequency: HKUpdateFrequency.Immediate, withCompletion: {(succeeded: Bool, error: NSError?) in
                
                if succeeded{
                    print("Enabled background delivery of step count changes")
                } else {
                    if let theError = error{
                        print("Failed to enable background delivery of step count changes. ")
                        print("Error = \(theError)")
                    }
                }
            })
        }
    }
    
    func stepCountChangedHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError? ) {
        completionHandler()
        print("in step count change handler")
        
        if let stepType = stepCountIdentifier, healthStore = healthStore {
            let anchor = NSUserDefaults.standardUserDefaults().integerForKey("stepAnchor")
            print(anchor)
            let query = HKAnchoredObjectQuery(type: stepType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, newSamples, newAnchor, error) -> Void in
                
                guard let samples = newSamples as? [HKQuantitySample] else {
                    // Add proper error handling here...
                    print("*** Unable to query for step counts: \(error?.localizedDescription) ***")
                    abort()
                }
                NSUserDefaults.standardUserDefaults().setInteger(newAnchor, forKey: "stepAnchor")
                print("new anchor for step count is ", NSUserDefaults.standardUserDefaults().integerForKey("stepAnchor"))
                
                if samples.count > 0 {
                    print("making parse objects: ", samples.count)
                    var stepObjects = [PFObject]()
                    for sample in samples {
                        let stepObject = PFObject(className: "StepObject")
                        stepObject["user"] = PFUser.currentUser()
                        stepObject["timestamp"] = sample.startDate
                        stepObject["quantity"] = sample.quantity.doubleValueForUnit(HKUnit.countUnit())
                        stepObjects.append(stepObject)
                    }
//                    PFObject.saveAllInBackground(stepObjects)
                    PFObject.saveAllInBackground(stepObjects) { (success, error) -> Void in
                        
                        if success {
                            print("successfully saved")
                        } else {
                            print("*** unable to save: \(error?.localizedDescription) ***")
                        }
                        
                    }
                    print("saving object")
                } else {
                    print("no samples")
                }
                print("Done!")
            }
            healthStore.executeQuery(query)
        }
    }
    
    func recentSteps(completion: ([HKQuantitySample]?, NSError?) -> () )
    {
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: endDate, options: [])
        
        // Our search predicate which will fetch data from now until a day ago
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: NSDate(), options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        if let stepType = type,  healthStore = self.healthStore {
            let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                completion(results as? [HKQuantitySample], error)
            }
            healthStore.executeQuery(query)
        }
        
    }
    
//    func perfromQueryForWeightSamples() {
//        let endDate = NSDate()
//        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Month,
//            value: -2, toDate: endDate, options: [])
//        
//        let weightSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
//        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate,
//            endDate: endDate, options: .None)
//        
//        let query = HKSampleQuery(sampleType: weightSampleType, predicate: predicate,
//            limit: 0, sortDescriptors: nil, resultsHandler: {
//                (query, results, error) in
//                if !results {
//                    println("There was an error running the query: \(error)")
//                }
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.weightSamples = results as! [HKQuantitySample]
//                    self.tableView.reloadData()
//                }
//        })
//        self.healthStore?.executeQuery(query)
//    }
}