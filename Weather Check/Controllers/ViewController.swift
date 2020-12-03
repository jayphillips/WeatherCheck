//
//  ViewController.swift
//  Weather Check
//
//  Created by Jay Phillips on 11/27/20.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var mainWeatherIcon: UIImageView!
    @IBOutlet weak var mainTempLabel: UILabel!
    @IBOutlet weak var mainStatusLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var forecastSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var firstWeatherIcon: UIImageView!
    @IBOutlet weak var firstTimeDayLabel: UILabel!
    @IBOutlet weak var firstTempLabel: UILabel!
    @IBOutlet weak var firstStatusLabel: UILabel!
    
    @IBOutlet weak var secondWeatherIcon: UIImageView!
    @IBOutlet weak var secondTimeDayLabel: UILabel!
    @IBOutlet weak var secondTempLabel: UILabel!
    @IBOutlet weak var secondStatusLabel: UILabel!
    
    @IBOutlet weak var thirdWeatherIcon: UIImageView!
    @IBOutlet weak var thirdTimeDayLabel: UILabel!
    @IBOutlet weak var thirdTempLabel: UILabel!
    @IBOutlet weak var thirdStatusLabel: UILabel!
    
    @IBOutlet weak var fourthWeatherIcon: UIImageView!
    @IBOutlet weak var fourthTimeDayLabel: UILabel!
    @IBOutlet weak var fourthTempLabel: UILabel!
    @IBOutlet weak var fourthStatusLabel: UILabel!
    
    @IBOutlet weak var fifthWeatherIcon: UIImageView!
    @IBOutlet weak var fifthTimeDayLabel: UILabel!
    @IBOutlet weak var fifthTempLabel: UILabel!
    @IBOutlet weak var fifthStatusLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    var result: Result?
    var currentCity = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentLocation()

    }
    
    func getCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func getCurrentWeather() {
        NetService.shared.getWeather { (result) in
            self.result = result
            self.result?.sortHourly()
            self.result?.sortDaily()
            self.updateUI()
        } onError: { (error) in
            debugPrint(error)
        }

    }
    
    func updateMainView(currentWeather: Current, city: String) {
        currentCityLabel.text = city
        mainTempLabel.text = "\(Int(currentWeather.temp.rounded()))°F"
        mainStatusLabel.text = currentWeather.weather[0].main
        let conditionID = currentWeather.weather[0].id
        mainWeatherIcon.image = UIImage(systemName: NetService.shared.getWeatherCondition(id: conditionID))
    }
    
    func updateWeekView(days: [Daily]) {
        let dayTempLabels = [firstTempLabel, secondTempLabel, thirdTempLabel, fourthTempLabel, fifthTempLabel]
        let dayIconImages = [firstWeatherIcon, secondWeatherIcon, thirdWeatherIcon, fourthWeatherIcon, fifthWeatherIcon]
        let dayStatusLabels = [firstStatusLabel, secondStatusLabel, thirdStatusLabel, fourthStatusLabel, fifthStatusLabel]
        let dayLabels = [firstTimeDayLabel, secondTimeDayLabel, thirdTimeDayLabel, fourthTimeDayLabel, fifthTimeDayLabel]
        
        for i in 0...4 {
            let day = days[i + 2]
            let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
            let dayString = Date.getDayOfWeekFrom(date: date)
            
            dayTempLabels[i]?.text = "\(Int(day.temp.day.rounded()))°F"
            dayIconImages[i]?.image = UIImage(systemName: NetService.shared.getWeatherCondition(id: day.weather[0].id))
            dayLabels[i]?.text = dayString
            dayStatusLabels[i]?.text = "\(day.weather[0].main)"
        }
    }
    
    func updateHourlyView(hours: [Hourly]) {
        let hourTempLabels = [firstTempLabel, secondTempLabel, thirdTempLabel, fourthTempLabel, fifthTempLabel]
        let hourIconImages = [firstWeatherIcon, secondWeatherIcon, thirdWeatherIcon, fourthWeatherIcon, fifthWeatherIcon]
        let hourStatusLabels = [firstStatusLabel, secondStatusLabel, thirdStatusLabel, fourthStatusLabel, fifthStatusLabel]
        let hourTimeLabels = [firstTimeDayLabel, secondTimeDayLabel, thirdTimeDayLabel, fourthTimeDayLabel, fifthTimeDayLabel]
        
        for i in 0...4 {
            let hour = hours[i + 1]
            let date = Date(timeIntervalSince1970: Double(hour.dt))
            let hourString = Date.getHour(date: date)
            
            hourTempLabels[i]?.text = "\(Int(hour.temp.rounded()))°F"
            hourIconImages[i]?.image = UIImage(systemName: NetService.shared.getWeatherCondition(id: hour.weather[0].id))
            hourStatusLabels[i]?.text = "\(hour.weather[0].main)"
            hourTimeLabels[i]?.text = hourString
        }
    }
    
    func clearView() {
        let labels = [firstTempLabel, firstStatusLabel, firstTimeDayLabel, secondTempLabel, secondStatusLabel, secondTimeDayLabel, thirdTempLabel, thirdStatusLabel, thirdTimeDayLabel, fourthTempLabel, fourthStatusLabel, fourthTimeDayLabel, fifthTempLabel, fifthStatusLabel, fifthTimeDayLabel]
        
        let icons = [firstWeatherIcon, secondWeatherIcon, thirdWeatherIcon, fourthWeatherIcon, fifthWeatherIcon]
        
        for label in labels {
            label?.text = ""
        }
        
        for icon in icons {
            icon?.image = nil
        }
    }
    
    func updateUI() {
        guard let result = result else { return }
        updateMainView(currentWeather: result.current, city: currentCity)
        currentDateLabel.text = Date.getDate()
        
        updateHourlyView(hours: result.hourly)
        
    }
    @IBAction func forecastSegmentSwitched(_ sender: Any) {
        guard let result = result else { return }
    
        switch forecastSegmentControl.selectedSegmentIndex {
        case 0:
            clearView()
            updateHourlyView(hours: result.hourly)
        case 1:
            clearView()
            updateWeekView(days: result.daily)
        default:
            break
        }
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitude = "\(location.coordinate.latitude)"
            let longitude = "\(location.coordinate.longitude)"
            
            NetService.shared.setLatitude(latitude)
            NetService.shared.setLongitude(longitude)
            
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { (placemark, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                if let placemark = placemark {
                    if placemark.count > 0 {
                        let placemark = placemark[0]
                        if let city = placemark.locality {
                            self.currentCity = city
                        }
                    }
                }
            }
            getCurrentWeather()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentCityLabel.text = "Location unavailable..."
    }
    
}

