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
    
    @IBOutlet weak var loadingView: UIView!
    var riskPercentage: Int = 0;
    var diagnostics: [String] = []
    var factors = "All the factors are in your favor"
    var prevention = "No urgent preventions need to be taken. Enjoy your day!"
    
    @IBOutlet weak var mainRiskLabel: UILabel!
    
    @IBOutlet weak var factorsTV: UITextView!
    @IBOutlet weak var preventionsTV: UITextView!
    
    @IBAction func getRisks(_ sender: UIButton) {
        print("Post Started")
        refreshRisk()
        // post request here
        print("Post ended")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        factorsTV.textContainer.lineBreakMode = .byCharWrapping
        preventionsTV.textContainer.lineBreakMode = .byCharWrapping
        
        loadingView.isHidden = true
       
        riskPercentage = Int(getHealthData(key: "risk"))!
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        refreshRisk()
        factorsTV.text = "We will load here the different factors explaining the risk"
        preventionsTV.text = "We will load here the different preventions to avoid the risk"
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
        factorsTV.text = "We will load here the different factors explaining the risk"
        factors = ""
        prevention = ""
        var weather = false
//        let preventions: [String: Bool] = []
//        preventions = ["": false, "": false, "": false, "": false]
        for diagnostic in diagnostics{
            switch(diagnostic){
            case("trend"):
                factors += "- The flu is trending in your area\n"
                prevention += "- \n"
            case("temparture"):
                factors += "- Forecast temparture gradient high\n"
                weather = true
            case("humidity"):
                factors += "- Extreme humidity values\n"
                weather = true
            case("wind"):
                factors += "- Overly windy\n"
                weather = true
            case("rain"):
                factors += "- Elevated precipitation\n"
                weather = true
            case("bmi"):
                factors += "- Out of range Body Mass Index\n"
                prevention += "- Improve your nutrition\n"
            case("heartrate"):
                factors += "- Unusual heartrate\n"
                prevention += "- Get a cardiovascular exam with a professional\n"
            case("steps"):
                factors += "- Not enough physical activity\n"
                prevention += "- Get more active\n"
            case("pollution"):
                factors += "- Low air quality\n"
                prevention += "- Wear a pollution mask\n"
            case("cigarettes"):
                factors += "- High cigarettes consumption\n"
                prevention += "- Stop smoking\n"
            case("sleep"):
                factors += "- Non-optimal sleep schedule\n"
                prevention += "- Sleep 8 hours on average per day\n"
            case("event"):
                factors += "- Increased risk with large nearby crowds"
                prevention += "- Avoid direct contact in the crowd\n"
            default:
                print("")
            }
        }
        if(weather){
            prevention += "- Avoid extreme weather conditions"
        }
        factorsTV.text = factors
        preventionsTV.text = prevention
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
        let origin = "172.20.10.11"
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
//                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let dict = self.convertToDictionary(text: responseString ?? "nil")
            self.riskPercentage = dict!["score"] as! Int
            self.diagnostics = dict!["diagnostic"] as! [String]
            print(self.diagnostics)
            print("responseString = \(String(responseString!))")
            self.setHealthData(key: "risk", value: String(self.riskPercentage))
            self.updateMainRiskLabel()
            self.loadingView.isHidden = true
            
        }
        
        self.loadingView.isHidden = false
        task.resume()
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
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

