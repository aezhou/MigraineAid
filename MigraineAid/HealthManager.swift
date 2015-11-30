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
        
        storage.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success,error:error)
            }
        }
    }
}