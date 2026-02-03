#if os(iOS)
import Foundation
import EventKit
import Observation
/// Handles requesting access and fetching events from the user's calendars (iOS + SwiftUI async/await).
@MainActor @Observable
class CalendarEventFetcher {
    
    // Represents the access status for calendar and reminder permissions
       enum AccessStatus {
           case authorized, denied, notDetermined
       }
    
    // Published properties to track current access status
    private let eventStore = EKEventStore()
    
    let today = Date()
    let oneWeekAfter = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    
    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            return granted
        } catch(let error) {
            return false
        }
    }
    
    
    /// Fetches calendar events between two dates (async/await).
    func fetchEvents() async throws -> [EKEvent] {
        let calendars = eventStore.calendars(for: .event)
        let access = await requestAccess()
        guard access else {
            return []
        }
       
        let predicate = eventStore.predicateForEvents(
            withStart: today,
            end: oneWeekAfter,
            calendars: calendars
        )
        return eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }
}

// MARK: - Errors

enum CalendarAccessError: Error, LocalizedError {
    case denied
    case unknown

    var errorDescription: String? {
        switch self {
        case .denied: return "Calendar access denied. Please allow access in Settings."
        case .unknown: return "Unknown error accessing calendar."
        }
    }
}
#endif
