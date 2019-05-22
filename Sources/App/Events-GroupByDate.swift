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

// MARK: LEGACY!!

extension Array where Element == JSONEvent {
    /// Returns the array sorted by the date
    func sortedByDate() -> [Element] {
        return sorted { lhs, rhs in
            guard let lhsDate = Calendar(identifier: .gregorian).date(from: lhs.startDate),
                let rhsDate = Calendar(identifier: .gregorian).date(from: rhs.startDate) else { return false }
            return lhsDate < rhsDate
        }
    }
}

extension Array where Element == LegacyJSONEventGroup {
    /// Returns the array sorted by the date
    func sortedByDate() -> [Element] {
        return sorted { lhs, rhs in
            guard let lhsDate = Calendar(identifier: .gregorian).date(from: lhs.date),
                let rhsDate = Calendar(identifier: .gregorian).date(from: rhs.date) else { return false }
            return lhsDate < rhsDate
        }
    }
}

extension Array where Element == JSONEvent {
    /// Groups the events by their date, returning an array of `EventGroup`s
    @available(*, deprecated, message: "Use `groupedAndSortedByDate()` instead")
    func legacyGroupedAndSortedByDate() -> [LegacyJSONEventGroup] {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .autoupdatingCurrent
        
        let groupedDictionary = [DateComponents: [JSONEvent]](grouping: self) { event in
            guard let date = Calendar(identifier: .gregorian).date(from: event.startDate) else { return event.startDate }
            var lessAccurateDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            lessAccurateDateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return lessAccurateDateComponents
        }
        
        let eventGroups = groupedDictionary.map { element in
            return LegacyJSONEventGroup(date: element.key, items: element.value.sortedByDate())
        }
        
        return eventGroups.sortedByDate()
    }
}
