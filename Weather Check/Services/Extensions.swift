//
//  Extensions.swift
//  Weather Check
//
//  Created by Jay Phillips on 11/27/20.
//

import Foundation

let date = Date()
let formatter = DateFormatter()

extension Date {
    
    static func getDate() -> String {
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    static func getHour(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            var hourString = formatter.string(from: date)
            
            if hourString.last == "M" {
                hourString = String(hourString.prefix(hourString.count - 2))
            }
            return hourString
        }
    
    static func getDayOfWeekFrom(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            var dayString = formatter.string(from: date)
            if let idx = dayString.firstIndex(of: ",") {
                dayString = String(dayString.prefix(upTo: idx))
                return dayString
            }
            return "error"
        }
}
