//
//  ViewController.swift
//  Helsana
//
//  Created by Jaafar Rammal on 9/28/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RisksController: UIViewController, CLLocationManagerDelegate {
    
    let healthData = UserDefaults.standard
    
    let locationManager = CLLocationManager()
    
    var riskPercentage = 50
    var risks = "There are no risks, you are safe!"
    var factors = "All the factors are in your favor"
    var prevention = "No urgent preventions need to be taken. Enjoy your day!"
    
    @IBOutlet weak var mainRiskLabel: UILabel!
    
    @IBAction func getRisks(_ sender: UIButton) {
        print("Post Started")
        refreshRisk()
        // post request here
        print("Post ended")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        updateMainRiskLabel()

    }
    
    func updateMainRiskLabel(){
        if(riskPercentage < 33){
            mainRiskLabel.text = "Low Risk of \(riskPercentage)%"
        }else{
            if(riskPercentage < 66){
                mainRiskLabel.text = "Medium Risk of \(riskPercentage)%"
            }else{
                mainRiskLabel.text = "High Risk of \(riskPercentage)%"
            }
        }
        
    }
    
    func setHealthData(key: String, value: String) {
        healthData.set(value, forKey: key)
    }
    
    func getHealthData(key: String) -> String {
        return healthData.string(forKey: key) ?? "0"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        // print("locations = \(locValue.latitude) \(locValue.longitude)")
        setHealthData(key: "latitude", value: String(locValue.latitude))
        setHealthData(key: "longitude", value: String(locValue.longitude))
    }
    
    func refreshRisk(){
        let origin = "172.20.10.12"
        let port  = "5000"
        
        let heartRate = getHealthData(key: "heartRate")
        let sleepHours = getHealthData(key: "sleepHours")
        let steps = getHealthData(key: "steps")
        let calories = getHealthData(key: "calories")
        let smokedCigarettes = getHealthData(key: "smokedCigarettes")
        let height = getHealthData(key: "weight")
        let weight = getHealthData(key: "height")
        let age = getHealthData(key: "age")
        let zipcode = 8005
        
        let url = URL(string: "http://\(origin):\(port)/fusion/" + getHealthData(key: "latitude") + "/" + getHealthData(key: "longitude") + "/\(zipcode)/\(heartRate)/\(steps)/\(smokedCigarettes)/\(sleepHours)/\(calories)/\(height)/\(weight)/\(age)")!
        print("URL is \(url)")
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            
            if let dico = data as? [String: Any] {
                if let score = dico["score"] as? String {
                    self.riskPercentage = Int(score) ?? -10
                }
                
                for (key, val) in dico {
                    print("key is \(key) and value is \(val)")
                }
            }
            print("responseString = \(String(responseString!))")
            self.updateMainRiskLabel()
        }
        
        task.resume()
        
    }
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

