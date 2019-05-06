import Leaf
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get { req -> Future<View> in
        struct Data: Codable {
            var eventGroups: [RenderedEventGroup]
        }
        
        let eventGroups = try getEventGroups().map { try renderEventGroup($0) }
        let data = Data(eventGroups: eventGroups)
        return try req.view().render("all", data)
    }
    
    router.get(String.parameter) { req -> Future<View> in
        let events = try getEventGroups().map { $0.items }.flatMap { $0 }
        let id = try req.parameters.next(String.self).lowercased().replacingOccurrences(of: "-", with: "")
        guard let event = events.first(where: { $0.id.lowercased() == id }) else {
            throw Abort(.forbidden)
        }
        
        let renderedEvent = try renderEvent(event)
        return try req.view().render("event", renderedEvent)
    }
}

public func getEventGroups() throws -> [EventGroup] {
    let directory = DirectoryConfig.detect().workDir
    let url = URL(fileURLWithPath: directory).appendingPathComponent("Public", isDirectory: true).appendingPathComponent("events.json")
    let data = try Data(contentsOf: url)
    
    let decoder = JSONDecoder()
    let groups = try decoder.decode([EventGroup].self, from: data)
    return groups
}

public func renderEventGroup(_ eventGroup: EventGroup) throws -> RenderedEventGroup {
    guard let date = Calendar(identifier: .gregorian).date(from: eventGroup.groupDate) else { throw Abort(.badRequest) }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM '\(daySuffix(for: date))'"
    let formattedDate = dateFormatter.string(from: date)
    
    let items = try eventGroup.items.map { try renderEvent($0) }
    return RenderedEventGroup(date: formattedDate, items: items)
}

public func renderEvent(_ event: Event) throws -> RenderedEvent {
    guard let location = event.location,
        let startDate = Calendar(identifier: .gregorian).date(from: event.startDate),
        let endDate = Calendar(identifier: .gregorian).date(from: event.endingDate) else {
        throw Abort(.badRequest)
    }
    
    /// Regex (regexr.com) matches all capital letters or numbers preceded by a lowercase letter to convert UpperCamelCase into hyphen-case
    let slug = event.id.replacingOccurrences(of: "([a-z])([A-Z]|[0-9])", with: "$1-$2", options: .regularExpression).lowercased()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM '\(daySuffix(for: startDate))'"
    let date = dateFormatter.string(from: startDate)
    
    let timeFormatter = DateFormatter()
    timeFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
    timeFormatter.timeStyle = .short
    timeFormatter.dateStyle = .none
    let time = timeFormatter.string(from: startDate) + " - " + timeFormatter.string(from: endDate)
    
    return RenderedEvent(id: event.id, slug: slug, name: event.title, description: event.description, date: date, time: time, latitude: location.latitude, longitude: location.longitude)
}

private func daySuffix(for date: Date) -> String {
    let day = Calendar(identifier: .gregorian).component(.day, from: date)
    
    if #available(OSX 10.11, *) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        return numberFormatter.string(from: NSNumber(value: day)) ?? String(day)
    } else {
        return String(day)
    }
}
