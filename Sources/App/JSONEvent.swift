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
    
    var imageLink: URL?
    var ticketLink: URL?
    var moreInfoLink: URL?
    
    init(id: String, tag: Event.Tag, requiredKind: String? = nil, title: String, description: String, startDate: DateComponents, endDate: DateComponents, place: String? = nil, latitude: Double, longitude: Double, ticketLink: String? = nil, moreInfoLink: String? = nil) {
        self.id = id
        self.tag = tag
        self.requiredKind = requiredKind
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.location = Coordinate(name: place, latitude: latitude, longitude: longitude)
        self.ticketLink = ticketLink != nil ? URL(string: ticketLink!) : nil
        self.moreInfoLink = moreInfoLink != nil ? URL(string: moreInfoLink!) : nil
        
        let directory = DirectoryConfig.detect().workDir
        let directoryURL = URL(fileURLWithPath: directory)
        let imagesDirectoryURL = directoryURL.appendingPathComponent("Public", isDirectory: true).appendingPathComponent("EventImages", isDirectory: true)
        
        let pngURL = imagesDirectoryURL.appendingPathComponent("\(id).png")
        let jpgURL = imagesDirectoryURL.appendingPathComponent("\(id).jpg")
        
        if let _ = try? Data(contentsOf: pngURL) {
            self.imageLink = URL(string: "https://events.wwdc.plus/EventImages/\(id).png")
        } else if let _ = try? Data(contentsOf: jpgURL) {
            self.imageLink = URL(string: "https://events.wwdc.plus/EventImages/\(id).jpg")
        }
    }
}
