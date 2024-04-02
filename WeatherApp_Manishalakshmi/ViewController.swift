//
//  ViewController.swift
//  WeatherApp_Manishalakshmi
//
//  Created by user237042 on 4/1/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var temperatureNumber: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    
    var Locationlatitude : Double = 0.0
    var Locationlongitude : Double = 0.0
    let apiKeyID = "d324702e67d2d8f98ceb69c10631e313"
    
    let locationManager : CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.first {
        Locationlatitude = location.coordinate.latitude
        Locationlongitude = location.coordinate.longitude
        getWeather(latitude: Locationlatitude, longitude: Locationlongitude)
      }
    }

    //To Get Weather Data
    func getWeather(latitude: Double, longitude: Double) {
        
      guard
        let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKeyID)&units=metric")
      else {
        return
      }

      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
          print("Error:", error)
          return
        }

        guard let data = data else {
          print("No data Found")
          return
        }

        do {
          let jsonDecoder = JSONDecoder()
          let weatherData = try jsonDecoder.decode(Temperatures.self, from: data)

          //To Update UI
          DispatchQueue.main.async {
              
            //To Set city name
            self.cityLabel.text = weatherData.name
              
            //To Set Weather
            self.weatherLabel.text = weatherData.weather.last?.main
            if let url = URL(
              string: "https://openweathermap.org/img/wn/\(weatherData.weather.last?.icon ?? "").png"
            ) {
                
            //To Set Weather Image
              self.getWeatherIcon(from: url)
            }
              
            //To Set Temperature
              self.temperatureNumber.text = "\(weatherData.main.temp) °C"
              
            //To Set Humidity
            self.humidityLabel.text = "Humdity : \(weatherData.main.humidity) %"
              
            //To Set Wind Speed
              self.windLabel.text = "Wind : \(weatherData.wind.speed!*3.6) km/h"
              
          }

        } catch {
          print("Error decoding the JSON:", error)
        }
      }
      task.resume()
    }

    func getWeatherIcon(from url: URL) {
      URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data else { return }

        if let error = error {
          print("Error downloading image: \(error.localizedDescription)")
          return
        }

        guard let image = UIImage(data: data) else {
          print("Failed to create image from data")
          return
        }

        DispatchQueue.main.async {
            
        //Set Weather Image
          self.weatherImage.image = image
        }
      }.resume()
    }


}

