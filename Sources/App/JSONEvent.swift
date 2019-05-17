//
//  Event-JSON.swift
//  App
//
//  Created by Julian Schiavo on 17/5/2019.
//

import Foundation
import Vapor

struct JSONEvent: Content, Codable, Hashable {
    var id: String
    var tag: Event.Tag
    var requiredKind: String?
    
    var title: String
    var description: String
    
    var startDate: DateComponents
    var endDate: DateComponents
    
    var location: Coordinate
    
    var ticketLink: URL?
    
    init(id: String, tag: Event.Tag, requiredKind: String? = nil, title: String, description: String, startDate: DateComponents, endDate: DateComponents, place: String? = nil, latitude: Double, longitude: Double, ticketLink: String? = nil) {
        self.id = id
        self.tag = tag
        self.requiredKind = requiredKind
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.location = Coordinate(name: place, latitude: latitude, longitude: longitude)
        self.ticketLink = ticketLink != nil ? URL(string: ticketLink!) : nil
    }
}
