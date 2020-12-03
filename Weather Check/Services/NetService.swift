//
//  NetService.swift
//  Weather Check
//
//  Created by Jay Phillips on 11/27/20.
//

import Foundation

class NetService {
    
    static let shared = NetService()
    
    private let apiKey = "f803af4f72996f22a80c3edaffb67c04"
    var urlLatitude = ""
    var urlLongitude = ""
    let baseURL = "https://api.openweathermap.org/data/2.5/onecall?"
    
    func setLatitude(_ latitude: String) {
        urlLatitude = latitude
    }
    
    func setLongitude(_ longitude: String) {
        urlLongitude = longitude
    }
    
    func getAPIKey() -> String {
        return apiKey
    }
    
    func getURL() -> String {
        return baseURL + "lat=" + urlLatitude + "&lon=" + urlLongitude + "&units=imperial" + "&appid=" + apiKey
    }
    
    func getWeatherCondition(id: Int) -> String {
        switch id {
        case 200...232:
            return "cloud.bolt.rain.fill"
        case 300...321:
            return "cloud.rain.fill"
        case 500...531:
            return "cloud.rain.fill"
        case 600...622:
            return "snow"
        case 701...781:
            return "cloud.fill"
        case 800:
            return "sun.max.fill"
        case 801...804:
            return "cloud.fill"
        default:
            return "No condition to return"
        }
    }
    
    let session = URLSession(configuration: .default)
    
    func getWeather(onSuccess: @escaping(Result) -> Void, onError: @escaping(String) -> Void) {
        guard let url = URL(string: getURL()) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid data or response from the server.")
                    return
                }
                
                do {
                    if response.statusCode == 200 {
                        let weather = try JSONDecoder().decode(Result.self, from: data)
                        onSuccess(weather)
                    }
                } catch {
                    onError(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
