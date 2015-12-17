//
//  HealthManager.swift
//  MigraineAid
//
//  Created by Amanda Zhou on 11/22/15.
//  Copyright © 2015 Amanda Zhou. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
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
    
    func recentSteps(completion: ([HKQuantitySample]?, NSError?) -> () )
    {
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: endDate, options: [])
        
        // Our search predicate which will fetch data from now until a day ago
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: NSDate(), options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        if let stepType = type {
            let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                completion(results as? [HKQuantitySample], error)
            }
            self.healthStore?.executeQuery(query)
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