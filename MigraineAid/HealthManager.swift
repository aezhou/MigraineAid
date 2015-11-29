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
    let storage = HKHealthStore()
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() -> Bool {
        // Default to assuming we're authorized
        var isEnabled = true
        
        if HKHealthStore.isHealthDataAvailable() {
            let heathKitTypesToRead: Set = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!, HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!, HKObjectType.workoutType()]
            
            storage.requestAuthorizationToShareTypes(nil, readTypes: heathKitTypesToRead, completion: {(success, error) -> Void in
                isEnabled = success
            })
        } else {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead: Set = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!, HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!, HKObjectType.workoutType()]
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        storage.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
}