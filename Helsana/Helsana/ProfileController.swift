//
//  ProfileController.swift
//  Helsana
//
//  Created by Jaafar Rammal on 9/28/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    let healthData = UserDefaults.standard
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    
    @IBAction func setName(_ sender: UITextField) {
        setHealthData(key: "name", value: sender.text!)
    }
    
    @IBAction func setDateOfBirth(_ sender: UITextField) {
        setHealthData(key: "age", value: sender.text!)
    }
    
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = "Profile"
        userImage.layer.cornerRadius = 75
        nameTF.text = getHealthData(key: "name")
        dateOfBirthTF.text = getHealthData(key: "age")
    }
    
    func setHealthData(key: String, value: String) {
        healthData.set(value, forKey: key)
    }
    
    func getHealthData(key: String) -> String {
        return healthData.string(forKey: key) ?? ""
    }
   
}
