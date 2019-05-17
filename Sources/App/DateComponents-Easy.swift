//
//  DateComponents-Easy.swift
//  App
//
//  Created by Julian Schiavo on 17/5/2019.
//

import Foundation

extension DateComponents {
    static func `default`(year: Int? = 2019, month: Int? = 6, day: Int, hour: Int, minute: Int? = 0, second: Int? = 0) -> DateComponents {
        return DateComponents(timeZone: TimeZone(identifier: "America/Los_Angeles"), year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
}
