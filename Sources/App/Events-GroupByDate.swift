//
//  Events-GroupByDate.swift
//  App
//
//  Created by Julian Schiavo on 17/5/2019.
//

import Foundation

extension Array where Element == Event {
    /// Returns the array sorted by the date
    func sortedByDate() -> [Element] {
        return sorted { lhs, rhs in
            return lhs.startDate < rhs.startDate
        }
    }
}

extension Array where Element == EventGroup {
    /// Returns the array sorted by the date
    func sortedByDate() -> [Element] {
        return sorted { lhs, rhs in
            return lhs.rawDate < rhs.rawDate
        }
    }
}

extension Array where Element == Event {
    /// Groups the events by their date, returning an array of `EventGroup`s
    func groupedAndSortedByDate() -> [EventGroup] {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .autoupdatingCurrent
        
        let groupedDictionary = [Date: [Event]](grouping: self) { event in
            var lessAccurateDateComponents = calendar.dateComponents([.year, .month, .day], from: event.startDate)
            lessAccurateDateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
            
            guard let lessAccurateDate = calendar.date(from: lessAccurateDateComponents) else { return event.startDate }
            return lessAccurateDate
        }
        
        let eventGroups = groupedDictionary.map { element in
            return EventGroup.new(date: element.key, events: element.value.sortedByDate())
        }
        
        return eventGroups.sortedByDate()
    }
}
