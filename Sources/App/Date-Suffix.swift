//
//  Date-Suffix.swift
//  App
//
//  Created by Julian Schiavo on 17/5/2019.
//

import Foundation

extension Date {
    var daySuffix: String {
        let day = Calendar(identifier: .gregorian).component(.day, from: self)
        
        if #available(OSX 10.11, *) {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .ordinal
            return numberFormatter.string(from: NSNumber(value: day)) ?? String(day)
        } else {
            return String(day)
        }
    }
}
