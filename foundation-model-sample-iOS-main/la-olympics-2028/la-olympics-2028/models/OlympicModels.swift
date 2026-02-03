import Foundation
import FoundationModels
// MARK: - Root Data Structure

@Generable
enum questionType: Codable {
    case rule
    case medals
    case other
}
@Generable
struct Category: Codable {
    let questionCategory: questionType
}

@Generable
struct Prompt: Codable {
    let name: String
    let response: String
}

@Generable(description: "Information About Olympic Schedule and Event Results")
struct OlympicData: Codable {
    let schedule: [OlympicDay]
    //let results: [OlympicResult]
}

// MARK: - Olympic Event Models
@Generable(description: "Information About Olympic Event including its date, time and venue")
struct OlympicEvent: Codable, Identifiable {
    let id = UUID()
    @Guide(.anyOf(["Archery", "Gymnastics", "Swimming", "Athletics", "Badminton", "Basketball", "Boxing", "Diving", "Equestrian"]))
    let sport: String
    let event: String
    let time: String
    let venue: String
    
    private enum CodingKeys: String, CodingKey {
        case sport, event, time, venue
    }
}

@Generable(description: "Information About Olympic schedule including all the events on that day")
struct OlympicDay: Codable, Identifiable {
    let id = UUID()
    let day: Int
    let date: String
    let events: [OlympicEvent]
    
    private enum CodingKeys: String, CodingKey {
        case day, date, events
    }
}

// MARK: - Olympic Statistics Models
@Generable(description: "Information About Athlete - name and what country they represent")
struct Athlete: Codable {
    let name: String
    let country: String
}

@Generable(description: "Information About placement of an athlete in an event")
struct Placement: Codable {
    let rank: Int
    let name: String
    let country: String
}

@Generable(description: "Information About result of an olympic event")
struct OlympicResult: Codable, Identifiable {
    let id = UUID()
    let sport: String
    @Guide(.anyOf(["Men", "Women"]))
    let gender: String?
    let event: String
    let goldMedalist: Athlete
    let silverMedalist: Athlete
    let bronzeMedalist: Athlete
    let placements: [Placement]?
    
    private enum CodingKeys: String, CodingKey {
        case sport, gender, event
        case goldMedalist = "gold_medalist"
        case silverMedalist = "silver_medalist"
        case bronzeMedalist = "bronze_medalist"
        case placements
    }
}

// MARK: - Virtual Assistant Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let scheduleData: [OlympicEvent]?
    let resultData: OlympicResult?
    
    init(content: String, isUser: Bool, timestamp: Date, scheduleData: [OlympicEvent]? = nil, resultData: OlympicResult? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.scheduleData = scheduleData
        self.resultData = resultData
    }
}

enum QueryType {
    case schedule
    case stats
    case rules
    case general
}

enum ChatResponseType {
    case text(String)
    case schedule([OlympicEvent])
    case result(OlympicResult)
    case textWithSchedule(String, [OlympicEvent])
    case textWithResult(String, OlympicResult)
}
