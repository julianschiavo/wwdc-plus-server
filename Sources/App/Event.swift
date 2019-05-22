//
//  Events.swift
//  App
//
//  Created by Julian Schiavo on 6/5/2019.
//

import Foundation
import Vapor

public struct Coordinate: Content, Codable, Hashable {
    var name: String?
    var latitude: Double
    var longitude: Double
    
    init(name: String? = nil, latitude: Double = 0, longitude: Double = 0) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct EventGroup: Codable {
    var rawDate: Date
    var date: String
    var events: [Event]
    
    static func new(date: Date, events: [Event]) -> EventGroup {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM '\(date.daySuffix)'"
        let formattedDate = dateFormatter.string(from: date)
        
        return EventGroup(rawDate: date, date: formattedDate, events: events)
    }
}

public struct Event: Codable, Hashable {
    public enum Tag: String, CaseIterable, Codable { // swiftlint:disable:this type_name
        case other = "Other"
        case podcast = "Podcast"
        case session = "Session"
        case meetup = "Get-Together"
        case specialEvent = "Special Event"
        
        var name: String {
            switch self {
            case .meetup:
                return "Meetup"
            case .specialEvent:
                return "Special"
            default:
                return rawValue
            }
        }
        
        var plural: String {
            return self == .other ? name : name + "s"
        }
    }
    
    var id: String
    var slug: String
    
    var name: String
    var description: String
    
    var startDate: Date
    var endDate: Date
    
    var date: String
    var time: String
    
    var placeName: String?
    var latitude: Double
    var longitude: Double
    
    var ticketLink: String?
    var moreInfoLink: String?
    
    static func from(_ event: JSONEvent) -> Event? {
        guard let startDate = Calendar(identifier: .gregorian).date(from: event.startDate),
            let endDate = Calendar(identifier: .gregorian).date(from: event.endDate) else { return nil }
        
        /// Regex (regexr.com) matches all capital letters or numbers preceded by a lowercase letter to convert UpperCamelCase into hyphen-case
        let slug = event.id.replacingOccurrences(of: "([a-z])([A-Z]|[0-9])", with: "$1-$2", options: .regularExpression).lowercased()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM '\(startDate.daySuffix)'"
        let date = dateFormatter.string(from: startDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        let time = timeFormatter.string(from: startDate) + " - " + timeFormatter.string(from: endDate)
        
        return Event(id: event.id,
                     slug: slug,
                     name: event.title,
                     description: event.description,
                     startDate: startDate,
                     endDate: endDate,
                     date: date,
                     time: time,
                     placeName: event.location.name,
                     latitude: event.location.latitude,
                     longitude: event.location.longitude,
                     ticketLink: event.ticketLink?.absoluteString,
                     moreInfoLink: event.moreInfoLink?.absoluteString)
    }
}
