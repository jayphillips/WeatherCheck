//
//  WeatherAPI.swift
//  Weather Check
//
//  Created by Jay Phillips on 11/27/20.
//

import Foundation

struct Result: Codable {
    let lat: Double
    let lon: Double
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]
    
    mutating func sortHourly() {
        hourly.sort { (hourOne: Hourly, hourTwo: Hourly) -> Bool in
            return hourOne.dt < hourTwo.dt
        }
    }
    
    mutating func sortDaily() {
            daily.sort { (dayOne, dayTwo) -> Bool in
                return dayOne.dt < dayTwo.dt
            }
        }
}

struct Current: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Int
    let temp: Temperature
    let weather: [Weather]
}

struct Temperature: Codable {
    let day: Double
}



