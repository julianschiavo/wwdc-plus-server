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
    func g() -> [String: [LegacyEvent]] {
        return [String: [LegacyEvent]](grouping: self, by: { el -> String in
            return el.title
        })
    }
    
    func grouped() -> [LegacyEventGroup] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .autoupdatingCurrent
        
        let groupedDictionary = [DateComponents: [LegacyEvent]](grouping: self) { event in
//            var lessAccurateDateComponents = event.startDate
//            lessAccurateDateComponents.hour = nil
//            lessAccurateDateComponents.minute = nil
//            lessAccurateDateComponents.second = nil
//            lessAccurateDateComponents.nanosecond = nil
//            return lessAccurateDateComponents
            return event.startDate
        }
        
        let eventGroups = groupedDictionary.map { item in
            return LegacyEventGroup(date: item.key, items: item.value)
        }
        
        return eventGroups
    }
}

