//
//  LegacySupport.swift
//  App
//
//  Created by Julian Schiavo on 22/5/2019.
//

import Foundation
import Vapor

struct LegacyEventGroup: Content, Codable {
    var date: DateComponents
    var items: [LegacyEvent]
}

extension Array where Element == LegacyEventGroup {
    func sortedByDate() -> [Element] {
        return sorted { lhs, rhs in
            guard let lhsDate = Calendar(identifier: .gregorian).date(from: lhs.date),
                let rhsDate = Calendar(identifier: .gregorian).date(from: rhs.date) else { return false }
            return lhsDate < rhsDate
        }
    }
}

struct LegacyEvent: Content, Codable {
    var id: String
    var tag: Event.Tag
    var requiredKind: String?
    
    var title: String
    var description: String
    
    var startDate: DateComponents
    var endDate: DateComponents
    
    var location: Coordinate
    
    var ticketLink: URL?
    
    static func from(_ event: JSONEvent) -> LegacyEvent {
        return LegacyEvent(id: event.id, tag: event.tag, requiredKind: event.requiredKind, title: event.title, description: event.description, startDate: event.startDate, endDate: event.endDate, location: event.location, ticketLink: event.ticketLink)
    }
}

extension Array where Element == LegacyEvent {
    func sortedByDate() -> [Element] {
        return sorted { lhs, rhs in
            guard let lhsDate = Calendar(identifier: .gregorian).date(from: lhs.startDate),
                let rhsDate = Calendar(identifier: .gregorian).date(from: rhs.startDate) else { return false }
            return lhsDate < rhsDate
        }
    }
}

extension Array where Element == LegacyEvent {
    func groupedtwo() -> [DateComponents: [LegacyEvent]] {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .autoupdatingCurrent
        
        let groupedDictionary = [DateComponents: [LegacyEvent]](grouping: self) { event in
            guard let date = Calendar(identifier: .gregorian).date(from: event.startDate) else { return event.startDate }
            var lessAccurateDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            lessAccurateDateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return lessAccurateDateComponents
        }
        
        return groupedDictionary
    }
    
    func grouped() -> [LegacyEventGroup] {
        print("Grouping events")
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .autoupdatingCurrent
        print("Calendar")
        let ggroupedDictionary = [Date: [LegacyEvent]](grouping: self) { event in
            guard let date = Calendar(identifier: .gregorian).date(from: event.startDate) else { return Date() }
            var lessAccurateDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            lessAccurateDateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
            
            guard let lessAccurateDate = calendar.date(from: lessAccurateDateComponents) else { return date }
            return lessAccurateDate
        }
        print("gg", ggroupedDictionary.count)
        let groupedDictionary = [DateComponents: [LegacyEvent]](grouping: self) { event in
            guard let date = Calendar(identifier: .gregorian).date(from: event.startDate) else { return event.startDate }
            var lessAccurateDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            lessAccurateDateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return lessAccurateDateComponents
        }
        print("g", groupedDictionary)
        let eventGroups = groupedDictionary.map { element in
            return LegacyEventGroup(date: element.key, items: element.value.sortedByDate())
        }
        print("eg", eventGroups)
        return eventGroups.sortedByDate()
    }
}

