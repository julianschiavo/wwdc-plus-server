//
//  Events.swift
//  App
//
//  Created by Julian Schiavo on 6/5/2019.
//

import Foundation

public struct Coordinate: Codable, Hashable {
    var name: String?
    var latitude: Double
    var longitude: Double
    
    init() {
        self.latitude = 0
        self.longitude = 0
    }
}

public struct EventGroup: Codable, Hashable {
    var groupDate: DateComponents
    
    var items: [Event]
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
    
    var id: String = ""
    var tag: Tag = .other
    
    var title: String = ""
    var description: String = ""
    
    var startDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    var endingDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    
    var location: Coordinate?
    
    var ticketLink: URL?
    
    init() { }
}

public struct RenderedEvent: Codable {
    var name: String
    var description: String
    
    var date: String
    var time: String
    
    var latitude: Double
    var longitude: Double
}
