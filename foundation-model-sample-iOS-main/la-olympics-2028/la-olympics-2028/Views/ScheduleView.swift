import SwiftUI

struct ScheduleView: View {
    @State var dataService = OlympicDataService()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataService.schedule) { day in
                    Section(header: Text("Day \(day.day) - \(formattedDate(day.date))")) {
                        ForEach(day.events) { event in
                            EventRowView(event: event)
                        }
                    }
                }
            }
            .navigationTitle("Olympic Schedule")
            .refreshable {
                // Refresh functionality could be added here
            }
//            .task {
//                let events = await dataService.eventsToAttend()
//            }
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

struct EventRowView: View {
    let event: OlympicEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.sport)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(event.time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(event.event)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Text(event.venue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}


