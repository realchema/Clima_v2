//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation


//adding delegate UITextFieldDelegate to be able to use searchTexrField.delegate = self (to listen the enter data from keyboard) and use methods like clean, etc to handle UITextField functions and properties
class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
     var localCity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        
        
        
        
        weatherManager.delegate = self
        locationManager.delegate = self
        searchTextField.delegate = self
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation()
        }
    }
    
    
    
  

}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: Any) {
        searchTextField.endEditing(true)
        
    }
    
    
    //get data when return button get pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    //
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }
        else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    
    //clean when stop return button from keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
            
        }
       
        searchTextField.text = ""
        

    }
    
    
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)  {
        temperatureLabel.text = weather.temperatureString
        conditionImageView.image = UIImage(systemName: weather.conditionName)
        cityLabel.text = weather.cityName
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}

//MARK: - CoreLocationManager

extension WeatherViewController: CLLocationManagerDelegate {
   
   
    
    @IBAction func locationPressed(_ sender: Any) {
        print(localCity)
        locationManager.requestLocation()
        weatherManager.fetchWeather(cityName: localCity)
        
    }
      
      
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")

        locationManager.stopUpdatingLocation()
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
                self.localCity = placemark.locality!
                
                self.localCity = self.localCity.folding(options: .diacriticInsensitive, locale: .current)
                
                self.weatherManager.fetchWeather(cityName: self.localCity)

            }
        }

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}

