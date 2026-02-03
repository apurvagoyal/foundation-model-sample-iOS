import SwiftUI

struct VirtualAssistantView: View {
    @State private var dataService = VirtualAssistantDataService()
    @State private var messages: [ChatMessage] = []
    @State private var currentInput: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                            
                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Assistant is typing...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input Area
                HStack {
                    TextField("Ask about Olympics...", text: $currentInput, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            Task{
                                messages.append(dataService.generateChatMessage(message: currentInput))
                                isLoading = true
                                let category = await dataService.questionCategory(message: currentInput)
                                
                                switch category.questionCategory {
                                case .rule:
                                    let message = try await dataService.generateContent(prompt: currentInput)
                                    messages.append(dataService.generateChatMessage(message: message))
                                    //messages.append(await dataService.generateContent(prompt: currentInput))
                                case .medals:
                                    messages.append(await dataService.query(query: currentInput))
                                case .other:
                                    messages.append(await dataService.query(query: currentInput))
                                }
                                
                                isLoading = false
                                isLoading = true
                                //messages.append(message)
                                let quiz = dataService.generateChatMessage(message: try await dataService.generateContent(prompt: AppStrings.quizQuestion))
                                messages.append(quiz)
                                let prompt = dataService.generateChatMessage(message: try await dataService.generateContent(prompt: AppStrings.promptNextQuestion))
                                isLoading = false
                                messages.append(prompt)
                            }
                        }
                        .disabled(isLoading)
                    
                    Button(action: {
                        Task{
                            messages.append(dataService.generateChatMessage(message: currentInput))
                            isLoading = true
                            let category = await dataService.questionCategory(message: currentInput)
                            
                            switch category.questionCategory {
                            case .rule:
                                let message = try await dataService.generateContent(prompt: currentInput)
                                messages.append(dataService.generateChatMessage(message: message))
                                //messages.append(await dataService.generateContent(prompt: currentInput))
                            case .medals:
                                messages.append(await dataService.query(query: currentInput))
                            case .other:
                                //should just return an error?
                                messages.append(ChatMessage(content: AppStrings.assistantAskAnything, isUser: false, timestamp: Date.now))
                            }
                            
                            isLoading = false
                            isLoading = true
                            let quiz = dataService.generateChatMessage(message: try await dataService.generateContent(prompt: AppStrings.quizQuestion))
                            messages.append(quiz)
                            let prompt = dataService.generateChatMessage(message: try await dataService.generateContent(prompt: AppStrings.promptNextQuestion))
                            isLoading = false
                            messages.append(prompt)
                        }
                    }) {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()
            }
            .navigationTitle("Olympic Assistant")
            .onAppear {
                if messages.isEmpty {
                    let welcomeMessage = dataService.getInitialMessage()
                    messages.append(welcomeMessage)
                }
                
            }
        }
    }
    
    private func sendMessage() async {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: currentInput,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        //let query = currentInput
        //currentInput = ""
        
        isLoading = true
        //send message to data service
        let response = await dataService.query(query: currentInput)
        messages.append(response)
        isLoading = false
        
    }
    
    
    
   
    
    
    func generateGeneralResponse() -> ChatResponseType {
        let responses = [
            "The 2028 Olympics will be held in Los Angeles! I can help you with schedules, results, and rules.",
            "I'm here to help with Olympic information! Ask me about game schedules, medal winners, or sport rules.",
            "Welcome to the Olympics! I can provide information about events, results, and how different sports work.",
            "The Olympic Games feature thousands of athletes competing in dozens of sports. What would you like to know?"
        ]
        
        return .text(responses.randomElement() ?? responses[0])
    }
    
//    func querySchedule(query: String) -> String {
//        if query.contains("today") {
//            let events = dataService.schedule.first?.events ?? []
//            var response = "Here's the schedule for July 26, 2028:\n\n"
//            
//            for event in events {
//                response += "🏃‍♂️ \(event.sport) - \(event.event)\n"
//                response += "⏰ \(event.time) at \(event.venue)\n\n"
//            }
//            
//            return response
//        } else {
//            return "I can help you with Olympic schedules! Try asking about specific dates or sports. For example: 'What's scheduled for today?' or 'When is swimming?'"
//        }
//    }
    
    func generateStatsResponse(query: String) -> String {
        if query.contains("archery") {
            let archeryResult = dataService.results.first { $0.sport.lowercased() == "archery" }
            if let result = archeryResult {
                return """
            🏹 Archery Men's Individual Results:
            
            🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
            🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
            🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
            
            Other top finishers:
            4th: \(result.placements?[0].name) (\(result.placements?[0].country))
            5th: \(result.placements?[1].name) (\(result.placements?[1].country))
            """
            }
        } else if query.contains("swimming") {
            let swimmingResult = dataService.results.first { $0.sport.lowercased() == "swimming" }
            if let result = swimmingResult {
                return """
            🏊‍♀️ Swimming Women's 100m Freestyle Results:
            
            🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
            🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
            🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
            
            Other finalists:
            4th: \(result.placements?[0].name) (\(result.placements?[0].country))
            5th: \(result.placements?[1].name) (\(result.placements?[1].country))
            """
            }
        }
        
        return "I can provide Olympic results and statistics! Try asking about specific sports like 'Who won archery?' or 'Swimming results'."
    }
    
    
    
    struct MessageView: View {
        let message: ChatMessage
        
        var body: some View {
            HStack {
                if message.isUser {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(message.content)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                        
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.content)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                            
                            Text(formatTime(message.timestamp))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        // Display schedule data if available
                        if let scheduleData = message.scheduleData, !scheduleData.isEmpty {
                            ScheduleDataView(events: scheduleData)
                        }
                        
                        // Display result data if available
                        if let resultData = message.resultData {
                            ResultDataView(result: resultData)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        
        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    struct ScheduleDataView: View {
        let events: [OlympicEvent]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 4) {
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
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 1)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
        }
    }
    
    struct ResultDataView: View {
        let result: OlympicResult
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(result.gender)'s \(result.event)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🥇")
                        Text("\(result.goldMedalist.name) (\(result.goldMedalist.country))")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("🥈")
                        Text("\(result.silverMedalist.name) (\(result.silverMedalist.country))")
                    }
                    
                    HStack {
                        Text("🥉")
                        Text("\(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))")
                    }
                    
                    
                    if result.placements != nil && !result.placements!.isEmpty {
                        Divider()
                        
                        Text("Other finalists:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        
                        ForEach(result.placements!.prefix(3), id: \.rank) { placement in
                            HStack {
                                Text("\(placement.rank)th")
                                    .frame(width: 30, alignment: .leading)
                                Text("\(placement.name) (\(placement.country))")
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
        }
    }
    
//    #Preview {
//        VirtualAssistantView()
//            .environmentObject(OlympicDataService())
//    }
}
