import Foundation
import Observation
import FoundationModels
import EventKit

@Observable
class OlympicDataService {
    var schedule: [OlympicDay] = []
    private var model = SystemLanguageModel(useCase: .general)
    private var session: LanguageModelSession?
    var isModelInitialized: Bool {
        model.availability == .available
    }
    
    init() {
        loadDataFromJSON()
    }
    
    private func loadDataFromJSON() {
        guard let url = Bundle.main.url(forResource: "olympicsschedule_updated", withExtension: "json") else {
            print("Could not find olympicsschedule.json file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let days = try decoder.decode([OlympicDay].self, from: data)
            let olympicData = OlympicData(schedule: days)
            self.schedule = olympicData.schedule
        } catch {
            print("Error loading JSON data: \(error)")
            
        }
    }
    
    /// Returns all OlympicDays whose date is within the next 7 days (including today)
    func getUpcomingWeekSchedule() -> [OlympicDay] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: today) else {
            return []
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return schedule.filter { day in
            guard let dayDate = formatter.date(from: day.date) else {
                return false
            }
            return (dayDate >= today) && (dayDate <= sevenDaysLater)
        }
    }
    
    func eventsToAttend() async -> [OlympicDay] {
        guard isModelInitialized else {
            return []
        }
        if session == nil {
            session = LanguageModelSession(instructions: AppStrings.modelInstructions)
        }
        do {
            let myEvents = try await events()
            let response = try await session!.respond(
                to: "Filter out all events from \(getUpcomingWeekSchedule()) that \(myEvents) find the OlympicDay from  that I can attend",
                generating: [OlympicDay].self
            )
            return response.content
        }
        catch (let error) {
            print(error.localizedDescription)
            return []
        }
    }
    
    func events() async throws -> [EKEvent]? {
        //find the calendar events for next 3 days
        let calendarEventFetcher = CalendarEventFetcher()
        do {
            let events = try await calendarEventFetcher.fetchEvents()
          
            return events
            //
        }
        catch (let error) {
            print (error)
        }
        return nil
    }
    
    func getEventsByDate(_ date: String) -> [OlympicEvent] {
        return schedule.first { $0.date == date }?.events ?? []
    }
    
//    func getResultsBySport(_ sport: String) -> [OlympicResult] {
//        return results.filter { $0.sport.lowercased() == sport.lowercased() }
//    }
    
    // MARK: - JSON Loading Methods
    
    /// Load Olympic data from a remote URL
    func loadFromURL(_ urlString: String) async {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let olympicData = try JSONDecoder().decode(OlympicData.self, from: data)
            
            await MainActor.run {
                self.schedule = olympicData.schedule
                //self.results = olympicData.results
            }
        } catch {
            print("Error loading data from URL: \(error)")
        }
    }
    
    /// Load Olympic data from JSON string (useful for testing or remote data)
    func loadFromJSONString(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            print("Could not convert string to data")
            return
        }
        
        do {
            let olympicData = try JSONDecoder().decode(OlympicData.self, from: data)
            
            DispatchQueue.main.async {
                self.schedule = olympicData.schedule
                //self.results = olympicData.results
            }
        } catch {
            print("Error decoding JSON string: \(error)")
        }
    }
    
    /// Reload data from the embedded JSON file
    func reloadData() {
        loadDataFromJSON()
    }
}
