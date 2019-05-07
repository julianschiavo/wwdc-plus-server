import Leaf
import Routing
import Vapor

public enum AppError: Error {
    public struct ErrorData: Codable {
        var title: String
        var description: String
    }
    
    case invalidEvent
    
    var data: ErrorData {
        switch self {
        case .invalidEvent:
            return ErrorData(title: "Invalid Event", description: "Make sure the event is valid or try again later.")
        }
    }
}

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
        let id = try req.parameters.next(String.self).replacingOccurrences(of: "-", with: "").lowercased()
        guard let event = events.first(where: { $0.id.lowercased() == id }) else {
            return try errorView(for: .invalidEvent, req: req)
        }
        
        let renderedEvent = try renderEvent(event)
        return try req.view().render("event", renderedEvent)
    }
}

public func errorView(for error: AppError, req: Request) throws -> Future<View> {
    return try req.view().render("error", error.data)
}

public func getEventGroups() throws -> [EventGroup] {
    let directory = DirectoryConfig.detect().workDir
    let url = URL(fileURLWithPath: directory).appendingPathComponent("Public", isDirectory: true).appendingPathComponent("all.json")
    let data = try Data(contentsOf: url)
    
    let decoder = JSONDecoder()
    let groups = try decoder.decode([EventGroup].self, from: data)
    return groups
}

public func renderEventGroup(_ eventGroup: EventGroup) throws -> RenderedEventGroup {
    guard let date = Calendar(identifier: .gregorian).date(from: eventGroup.date) else { throw Abort(.badRequest) }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM '\(daySuffix(for: date))'"
    let formattedDate = dateFormatter.string(from: date)
    
    let items = try eventGroup.items.map { try renderEvent($0) }
    return RenderedEventGroup(date: formattedDate, items: items)
}

public func renderEvent(_ event: Event) throws -> RenderedEvent {
    guard let startDate = Calendar(identifier: .gregorian).date(from: event.startDate),
        let endDate = Calendar(identifier: .gregorian).date(from: event.endDate) else {
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
    
    return RenderedEvent(id: event.id,
                         slug: slug,
                         name: event.title,
                         description: event.description,
                         date: date,
                         time: time,
                         latitude: event.location.latitude,
                         longitude: event.location.longitude,
                         hasTicketLink: event.ticketLink != nil,
                         ticketLink: event.ticketLink?.absoluteString)
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
