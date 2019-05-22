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
            var eventGroups: [EventGroup]
        }
        
        let eventGroups = JSONEvent.all.compactMap(Event.from).groupedAndSortedByDate()
        let data = Data(eventGroups: eventGroups)
        return try req.view().render("all", data)
    }
    
    router.get(String.parameter) { req -> Future<View> in
        let events = JSONEvent.all.compactMap(Event.from)
        let id = try req.parameters.next(String.self).replacingOccurrences(of: "-", with: "").lowercased()
        
        guard let event = events.first(where: { $0.id.lowercased() == id }) else {
            return try errorView(for: .invalidEvent, req: req)
        }
        
        return try req.view().render("event", event)
    }
    
    router.get("api", Int.parameter, "events") { req -> [JSONEvent] in
        return JSONEvent.all
    }
    
    router.get("allllll") { req -> [LegacyEventGroup] in
        return JSONEvent.all.map(LegacyEvent.from).grouped()
    }
}

public func errorView(for error: AppError, req: Request) throws -> Future<View> {
    return try req.view().render("error", error.data)
}
//
//public func getEventGroups() throws -> [EventGroup] {
//    let directory = DirectoryConfig.detect().workDir
//    let url = URL(fileURLWithPath: directory).appendingPathComponent("Public", isDirectory: true).appendingPathComponent("all.json")
//    let data = try Data(contentsOf: url)
//
//    let decoder = JSONDecoder()
//    let groups = try decoder.decode([EventGroup].self, from: data)
//    return groups
//}
//
