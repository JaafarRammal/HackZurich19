//
//  MainScreen.swift
//  Helsana
//
//  Created by Jaafar Rammal on 9/29/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

import UIKit
import HealthKit

class MainScreen: UIViewController{
    
    let healthStore = HKHealthStore()
    let healthData = UserDefaults.standard
    
    @IBOutlet weak var risk: UILabel!
    
    @IBOutlet weak var riskSummary: UIView!
    @IBOutlet weak var healthSummary: UIView!
    
    @IBAction func openHealthApp(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "x-apple-health://")!)
    }
    var riskPercentage = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Main Menu"
        
        riskPercentage = Int(healthData.string(forKey: "risk") ?? "0")!
        risk.text = "\(riskPercentage)%"
     
        riskSummary.layer.cornerRadius = 15
        healthSummary.layer.cornerRadius = 15
        
        let typestoRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.highHeartRateEvent)!,
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.lowHeartRateEvent)!
            ])
        
        let typestoShare = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
            if success == false {
                NSLog(" Display not allowed")
            }
        }
        
    }
    
    
}


