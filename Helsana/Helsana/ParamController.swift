//
//  ParamController.swift
//  Helsana
//
//  Created by Jaafar Rammal on 9/28/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

import UIKit
import QuartzCore

class ParamController: UIViewController {
    
    let healthData = UserDefaults.standard
    
    @IBOutlet weak var heartRateTF: UITextField!
    @IBOutlet weak var sleepHourTF: UITextField!
    @IBOutlet weak var stepsTF: UITextField!
    @IBOutlet weak var caloriesTF: UITextField!
    @IBOutlet weak var smokedCigarettesTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBAction func setHeartRate(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "heartRate", value: sender.text!)}
        updateView()
    }
    
    @IBAction func setSleepHours(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "sleepHours", value: sender.text!)}
        updateView()
    }
    
    @IBAction func setSteps(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "steps", value: sender.text!)}
        updateView()
    }
    
    @IBAction func setCalories(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "calories", value: sender.text!)}
        updateView()
    }
    
    @IBAction func setSmokedCigarettes(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "smokedCigarettes", value: sender.text!)}
        updateView()
    }
    
    @IBAction func setHeight(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "height", value: sender.text!)}
        updateView()
    }
    
    @IBAction func setWeight(_ sender: UITextField) {
        if(sender.text != ""){setHealthData(key: "weight", value: sender.text!)}
        updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateView()
        self.title = "Health Data"
    }
    
    func setHealthData(key: String, value: String) {
        healthData.set(value, forKey: key)
    }
    
    func getHealthData(key: String) -> String {
        return healthData.string(forKey: key) ?? "0"
    }
    
    func updateView(){
        heartRateTF.text = getHealthData(key: "heartRate")
        if(heartRateTF.text != ""){
            heartRateTF.text! = heartRateTF.text! + " BPM"
        }
        sleepHourTF.text = getHealthData(key: "sleepHours")
        stepsTF.text = getHealthData(key: "steps")
        caloriesTF.text = getHealthData(key: "calories")
        if(caloriesTF.text != ""){
            caloriesTF.text! = caloriesTF.text! + " KJ"
        }
        smokedCigarettesTF.text = getHealthData(key: "smokedCigarettes")
        weightTF.text = getHealthData(key: "weight")
        if(weightTF.text != ""){
            weightTF.text! = weightTF.text! + " KG"
        }
        heightTF.text = getHealthData(key: "height")
        if(heightTF.text != ""){
            heightTF.text! = heightTF.text! + " cm"
        }
    }
}
