import Foundation
import Combine
import FoundationModels

class VirtualAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isLoading: Bool = false
    
    private let dataService: OlympicDataService
    private var model = SystemLanguageModel.default
    //will instantiate it only if the model is supported
    @Published var session: LanguageModelSession?
    
    init(dataService: OlympicDataService) {
        self.dataService = dataService
        if model.availability == .available {
            session = LanguageModelSession {
                """
                You are a friendly virtual olympics stats assistant. Greet the user warmly
                and provide clear, helpful olympic stats related information only. If user asks for anything outside of olympics stats kindly refuse or apologize
                """
            }
            // Welcome message
            messages.append(ChatMessage(
                content: "Hello! I'm your Olympic assistant. Ask me about Olympic schedules, statistics, or game rules!",
                isUser: false,
                timestamp: Date()
            )
                            )
        }
        else{
            messages.append(ChatMessage(
                content: ModelError.modelNotAvailable.localizedDescription,
                isUser: false,
                timestamp: Date()
            )
                            )
        }
    }
    
    //function to check status of foundation model availability
     
    
    func sendMessage() async {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && session != nil && !session!.isResponding else { return }
        
        let userMessage = ChatMessage(
            content: currentInput,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let query = currentInput
        currentInput = ""
        
        isLoading = true
        let response = await processQuery(query)
        let assistantMessage = ChatMessage(
            content: response,
            isUser: false,
            timestamp: Date()
        )
        self.messages.append(assistantMessage)
        self.isLoading = false
       
    }
    
    private func processQuery(_ query: String) async -> String {
        let lowercaseQuery = query.lowercased()
        
        guard let session else {
            return ModelError.modelNotAvailable.localizedDescription
        }
       
        do {
            let sportResult = try await session.respond(to: "Hello, who won the Italian Football Championship in 2023?")
            print(sportResult.content)
            
//                let response = try await session.respond(
//                    to: Prompt(lowercaseQuery),
//                    generating: OlympicResult.self,
//                    includeSchemaInPrompt: false,
//                    options: GenerationOptions(temperature: 0.5)
//                )
            
//            let response = try await session.streamResponse(
//                to: Prompt(lowercaseQuery),
//                generating: OlympicResult.self,
//                includeSchemaInPrompt: false,
//                options: GenerationOptions(temperature: 0.5)
//            )
            
                // Use response as needed, e.g.:
           // let result: OlympicResult = response.content
            //return generateStringResponse(result: result)
            return sportResult.content
        } catch (let err){
            // Handle the error, return a user-friendly message or log as needed
            print(err.localizedDescription)
            return ModelError.unknown.localizedDescription
        }
        /**
        //Send the query to model
        return generateScheduleResponse(query: lowercaseQuery)
        
        // Schedule queries
        if lowercaseQuery.contains("schedule") || lowercaseQuery.contains("when") || lowercaseQuery.contains("time") {
            return generateScheduleResponse(query: lowercaseQuery)
        }
        
        // Statistics queries
        if lowercaseQuery.contains("medal") || lowercaseQuery.contains("winner") || lowercaseQuery.contains("result") || lowercaseQuery.contains("gold") {
            return generateStatsResponse(query: lowercaseQuery)
        }
        
        // Rules queries
        if lowercaseQuery.contains("rule") || lowercaseQuery.contains("how to") || lowercaseQuery.contains("scoring") {
            return generateRulesResponse(query: lowercaseQuery)
        }
        
        // General Olympic information
        return generateGeneralResponse()
         **/
    }
    func generateStringResponse(result: OlympicResult) -> String {
        return """
                🏊‍♀️ \(result.sport) \(result.gender) \(result.event) Results:
                
                🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
                🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
                🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
                
                Other finalists:
                4th: \(result.placements?[0].name) (\(result.placements?[0].country))
                5th: \(result.placements?[1].name) (\(result.placements?[1].country))
                """
    }

    private func generateScheduleResponse(query: String) -> String {
        if query.contains("today") || query.contains("july 26") {
            let events = dataService.schedule.first?.events ?? []
            var response = "Here's the schedule for July 26, 2028:\n\n"
            
            for event in events {
                response += "🏃‍♂️ \(event.sport) - \(event.event)\n"
                response += "⏰ \(event.time) at \(event.venue)\n\n"
            }
            
            return response
        } else {
            return "I can help you with Olympic schedules! Try asking about specific dates or sports. For example: 'What's scheduled for today?' or 'When is swimming?'"
        }
    }
    
//    private func generateStatsResponse(query: String) -> String {
//        if query.contains("archery") {
//            let archeryResult = dataService.results.first { $0.sport.lowercased() == "archery" }
//            if let result = archeryResult {
//                return """
//                🏹 Archery Men's Individual Results:
//                
//                🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
//                🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
//                🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
//                
//                Other top finishers:
//                4th: \(result.placements[0].name) (\(result.placements[0].country))
//                5th: \(result.placements[1].name) (\(result.placements[1].country))
//                """
//            }
//        } else if query.contains("swimming") {
//            let swimmingResult = dataService.results.first { $0.sport.lowercased() == "swimming" }
//            if let result = swimmingResult {
//                return """
//                🏊‍♀️ Swimming Women's 100m Freestyle Results:
//                
//                🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
//                🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
//                🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
//                
//                Other finalists:
//                4th: \(result.placements[0].name) (\(result.placements[0].country))
//                5th: \(result.placements[1].name) (\(result.placements[1].country))
//                """
//            }
//        }
//        
//        return "I can provide Olympic results and statistics! Try asking about specific sports like 'Who won archery?' or 'Swimming results'."
//    }
    
    private func generateRulesResponse(query: String) -> String {
        if query.contains("archery") {
            return """
            🏹 Archery Rules Summary:
            
            • Archers shoot arrows at a target 70 meters away
            • Target has 10 scoring rings (1-10 points)
            • Gold center ring (bullseye) = 10 points
            • Competition format: Ranking round + elimination rounds
            • Each archer shoots 6 arrows per end
            • Winner determined by highest total score
            """
        } else if query.contains("swimming") {
            return """
            🏊‍♀️ Swimming Rules Summary:
            
            • Races held in 50-meter pools
            • Freestyle: Any stroke allowed (usually front crawl)
            • False starts result in disqualification
            • Swimmers must touch the wall to finish
            • Lane assignments based on qualifying times
            • Fastest qualifier gets center lane
            """
        } else if query.contains("basketball") {
            return """
            🏀 Olympic Basketball Rules:
            
            • Games are 4 quarters of 10 minutes each
            • 5 players per team on court
            • 3-point line at 6.75 meters
            • 24-second shot clock
            • Tournament format with group stage and knockouts
            • FIBA rules apply (slightly different from NBA)
            """
        }
        
        return "I can explain Olympic rules for various sports! Try asking about specific sports like 'Archery rules' or 'How does basketball work?'"
    }
    
    private func generateGeneralResponse() -> String {
        let responses = [
            "The 2028 Olympics will be held in Los Angeles! I can help you with schedules, results, and rules.",
            "I'm here to help with Olympic information! Ask me about game schedules, medal winners, or sport rules.",
            "Welcome to the Olympics! I can provide information about events, results, and how different sports work.",
            "The Olympic Games feature thousands of athletes competing in dozens of sports. What would you like to know?"
        ]
        
        return responses.randomElement() ?? responses[0]
    }
}
