import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }
            
            VirtualAssistantView()
                .tabItem {
                    Image(systemName: "message.circle")
                    Text("Assistant")
                }
        }
        .accentColor(.blue)
    }
}

