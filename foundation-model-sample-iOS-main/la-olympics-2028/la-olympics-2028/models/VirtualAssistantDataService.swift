//
//  VirtualAssistantDataService.swift
//  la-olympics-2028
//
//  Created by Goyal, Apurva on 8/27/25.
//

import Foundation
import Observation
import FoundationModels

@Observable
class VirtualAssistantDataService {
    
    // MARK: - Properties
    
    /// Cached Olympic results data
    var results: [OlympicResult] = []
    
    /// Language model specialized for content tagging
    private let contentTaggingModel = SystemLanguageModel(useCase: .contentTagging)
    
    /// Language model for general-purpose text generation
    private let generalModel = SystemLanguageModel(useCase: .general)
    
    /// Language model for sport and event matching
    private let matchingModel = SystemLanguageModel(useCase: .general)
    
    /// Session for content tagging operations
    private var contentTaggingSession: LanguageModelSession?
    
    /// Session for general text generation operations
    private var generalSession: LanguageModelSession?
    
    /// Session for sport/event matching operations
    private var matchingSession: LanguageModelSession?
    
    // MARK: - Computed Properties
    
    /// Indicates whether the content tagging model is available
    var isContentTaggingModelAvailable: Bool {
        contentTaggingModel.availability == .available
    }
    
    /// Indicates whether the general model is available
    var isGeneralModelAvailable: Bool {
        generalModel.availability == .available
    }
    
    /// Indicates whether the matching model is available
    var isMatchingModelAvailable: Bool {
        matchingModel.availability == .available
    }
    
    // MARK: - Initialization
    
    /// Initializes the assistant and returns the welcome message
    func getInitialMessage() -> ChatMessage {
        guard isContentTaggingModelAvailable else {
            return createChatMessage(
                content: ModelError.modelNotAvailable.localizedDescription
            )
        }
        
        // Initialize content tagging session
        contentTaggingSession = LanguageModelSession(
            instructions: AppStrings.contentTaggingInstructions
        )
        
        return createChatMessage(content: AppStrings.assistantGreeting)
    }
    
    /// Pre-warms the models for faster response times (future implementation)
    func preWarm() {
        // TODO: Implement model pre-warming if needed
    }
    
    // MARK: - Public Query Methods
    
    /// Processes a user query and returns an assistant response
    /// - Parameter query: The user's question or request
    /// - Returns: A chat message with the assistant's response
    func query(query: String) async -> ChatMessage {
        // Validate session
        guard let session = contentTaggingSession else {
            return createChatMessage(content: AppStrings.assistantUnavailable)
        }
        
        guard !session.isResponding else {
            return createChatMessage(content: AppStrings.assistantBusy)
        }
        
        do {
            // Extract content tags from the query
            let queryTags = try await extractContentTags(from: query)
            
            guard !queryTags.topics.isEmpty else {
                return createChatMessage(content: AppStrings.assistantSomethingWrong)
            }
            
            // Process the query with extracted tags
            let response = await processOlympicQuery(
                keywords: queryTags.topics,
                gender: queryTags.gender
            )
            
            return createChatMessage(content: response)
            
        } catch {
            print("Query error: \(error.localizedDescription)")
            return createChatMessage(content: AppStrings.assistantSomethingWrong)
        }
    }
    
    /// Classifies a message into a question category
    /// - Parameter message: The message to classify
    /// - Returns: The category of the question
    func questionCategory(message: String) async -> Category {
        guard isGeneralModelAvailable else {
            return Category(questionCategory: .other)
        }
        
        generalSession = LanguageModelSession(
            instructions: AppStrings.modelInstructions
        )
        
        do {
            let response = try await generalSession!.respond(
                to: "Classify \(message) into one of the following categories - question about rules of a sport, question about a sporting event result or others",
                generating: Category.self
            )
            return response.content
            
        } catch {
            print("Category classification error: \(error.localizedDescription)")
            return Category(questionCategory: .other)
        }
    }
    
    /// Generates content based on a prompt
    /// - Parameter prompt: The instruction for content generation
    /// - Returns: Generated content string
    func generateContent(prompt: String) async throws -> String {
        guard isGeneralModelAvailable else {
            return AppStrings.assistantUnavailable
        }
        
        generalSession = LanguageModelSession()
        
        do {
            let response = try await generalSession!.respond(
                to: prompt,
                generating: Prompt.self
            )
            return response.content.response
            
        } catch {
            print("Content generation error: \(error.localizedDescription)")
            return AppStrings.assistantGenericError
        }
    }
    
    // MARK: - Private Helper Methods - Content Tagging
    
    /// Extracts content tags from a user query using the content tagging model
    /// - Parameter query: The user's query string
    /// - Returns: Extracted content tags including topics and gender
    /// - Throws: ModelError if tagging fails
    private func extractContentTags(from query: String) async throws -> ContentTaggingResult {
        guard let session = contentTaggingSession else {
            throw ModelError.notInitialized
        }
        
        do {
            let response = try await session.respond(
                to: query,
                generating: ContentTaggingResult.self
            )
            return response.content
            
        } catch {
            print("Content tagging error: \(error.localizedDescription)")
            throw ModelError.unknown
        }
    }
    
    /// Matches user query keywords to actual event names in the dataset
    /// - Parameters:
    ///   - keywords: Keywords extracted from user query
    ///   - availableData: Sample of available sports and events from the dataset
    /// - Returns: Matched sports and event names
    /// - Throws: ModelError if matching fails
    private func matchEventsUsingAI(keywords: [String], availableData: String) async throws -> MatchedEvents {
        guard isMatchingModelAvailable else {
            throw ModelError.notInitialized
        }
        
        // Create a new matching session with specialized instructions
        matchingSession = LanguageModelSession(
            instructions: AppStrings.eventMatchingInstructions
        )
        
        let prompt = """
        User query keywords: \(keywords.joined(separator: ", "))
        
        Available Olympic sports and events in the dataset:
        \(availableData)
        
        Task: Match the user's query to relevant events from the available data.
        
        Matching rules:
        - If query is SPECIFIC (e.g., "100m", "singles", "relay"), return ONLY that specific event
        - If query is BROAD (e.g., just "badminton", "swimming"), return ALL related events
        - "100 meter" or "100m" → match ONLY "100m" events (NOT 100m Relay, NOT 200m)
        - "badminton" alone → return ["Singles", "Doubles", "Mixed Doubles"]
        - "swimming" alone → return ALL swimming events
        - "freestyle" → match ALL freestyle distances
        
        Specificity guidelines:
        - Fewer keywords (1-2) = broad match → return multiple events
        - More keywords (3+) or very specific terms = narrow match → return 1 specific event
        
        Return:
        - sports: The sport name (e.g., "Badminton")
        - events: Event names as they appear in data
          * Broad query: ["Singles", "Doubles", "Mixed Doubles"]
          * Specific query: ["100m"]
        """
        
        do {
            let response = try await matchingSession!.respond(
                to: prompt,
                generating: MatchedEvents.self
            )
            return response.content
            
        } catch {
            print("Event matching error: \(error.localizedDescription)")
            throw ModelError.unknown
        }
    }
    
    /// Generates a summary of available sports and events from the dataset
    /// - Parameter results: Olympic results data
    /// - Returns: Formatted string listing unique sports and their events
    private func generateAvailableEventsDescription(from results: [OlympicResult]) -> String {
        var sportEventsMap: [String: Set<String>] = [:]
        
        // Group events by sport
        for result in results {
            if sportEventsMap[result.sport] == nil {
                sportEventsMap[result.sport] = Set<String>()
            }
            sportEventsMap[result.sport]?.insert(result.event)
        }
        
        // Format as readable text
        var description = ""
        for (sport, events) in sportEventsMap.sorted(by: { $0.key < $1.key }) {
            description += "\n\(sport):\n"
            for event in events.sorted() {
                description += "  - \(event)\n"
            }
        }
        
        return description
    }
    
    // MARK: - Private Helper Methods - Data Processing
    
    /// Processes an Olympic-related query by searching and filtering results
    /// - Parameters:
    ///   - keywords: Topics extracted from the query
    ///   - gender: Gender filter for events
    /// - Returns: Formatted response string
    private func processOlympicQuery(keywords: [String], gender: [String]) async -> String {
        // Load Olympic results data
        guard let results = loadOlympicResults() else {
            return AppStrings.assistantCannotFindFile
        }
        
        // Try AI-enhanced matching first for better results
        do {
            // Generate description of available data
            let availableData = generateAvailableEventsDescription(from: results)
            
            // Use AI to match keywords to actual event names
            let matchedEvents = try await matchEventsUsingAI(
                keywords: keywords,
                availableData: availableData
            )
            
            print("🤖 AI Matched - Sports: \(matchedEvents.sports), Events: \(matchedEvents.events)")
            
            // Use AI-matched keywords for more precise filtering
            var aiFilteredResults: [OlympicResult] = []
            
            // First, filter by sport if matched
            if !matchedEvents.sports.isEmpty {
                aiFilteredResults = results.filter { result in
                    matchedEvents.sports.contains { sport in
                        result.sport.lowercased() == sport.lowercased()
                    }
                }
            } else {
                aiFilteredResults = results
            }
            
            // Then, filter by event if matched
            if !matchedEvents.events.isEmpty {
                aiFilteredResults = aiFilteredResults.filter { result in
                    let resultEvent = result.event.lowercased()
                    return matchedEvents.events.contains { event in
                        resultEvent.contains(event.lowercased()) || event.lowercased().contains(resultEvent)
                    }
                }
            }
            
            print("🔍 AI Filtered Results: \(aiFilteredResults.count) matches")
            
            if !aiFilteredResults.isEmpty {
                // Apply gender filter if provided
                let genderFilteredResults = applyGenderFilter(to: aiFilteredResults, gender: gender)
                
                if !genderFilteredResults.isEmpty {
                    return await generateResponse(for: genderFilteredResults)
                }
            }
        } catch {
            print("AI matching failed, falling back to simple matching: \(error.localizedDescription)")
        }
        
        // Fallback: Use simple keyword matching
        let keywordsLowercased = keywords.map { $0.lowercased() }
        let filteredResults = filterResultsByKeywords(results, keywords: keywordsLowercased)
        
        guard !filteredResults.isEmpty else {
            return AppStrings.assistantNoSpecificResults
        }
        
        // Apply gender filter if provided
        let genderFilteredResults = applyGenderFilter(to: filteredResults, gender: gender)
        
        guard !genderFilteredResults.isEmpty else {
            return AppStrings.assistantNoSpecificResults
        }
        
        // Generate response based on number of results
        return await generateResponse(for: genderFilteredResults)
    }
    
    /// Loads Olympic results from the JSON file
    /// - Returns: Array of OlympicResult objects, or nil if loading fails
    private func loadOlympicResults() -> [OlympicResult]? {
        guard let url = Bundle.main.url(forResource: "olympicsdata", withExtension: "json") else {
            print("Could not find olympicsdata.json file")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([OlympicResult].self, from: data)
            
        } catch {
            print("Error loading JSON data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Filters results based on provided keywords
    /// - Parameters:
    ///   - results: Olympic results to filter
    ///   - keywords: Keywords to match against
    /// - Returns: Filtered results
    private func filterResultsByKeywords(_ results: [OlympicResult], keywords: [String]) -> [OlympicResult] {
        return results.filter { result in
            let fields = [result.sport, result.event].map { $0.lowercased() }
            return keywords.contains { keyword in
                fields.contains(where: { field in keyword.contains(field) })
            }
        }
    }
    
    /// Applies gender filter to results
    /// - Parameters:
    ///   - results: Results to filter
    ///   - gender: Gender filter array
    /// - Returns: Gender-filtered results
    private func applyGenderFilter(to results: [OlympicResult], gender: [String]) -> [OlympicResult] {
        guard !gender.isEmpty else {
            return results
        }
        
        let resultsWithGender = results.filter { $0.gender != nil }
        guard !resultsWithGender.isEmpty else {
            return []
        }
        
        return resultsWithGender.filter {
            $0.gender!.lowercased() == gender[0].lowercased()
        }
    }
    
    /// Generates an appropriate response based on the number of results
    /// - Parameter results: Filtered Olympic results
    /// - Returns: Formatted response string
    private func generateResponse(for results: [OlympicResult]) async -> String {
        guard results.count == 1 else {
            // Multiple results - generate a summary
            return (try? await generateSummary(for: results)) ?? AppStrings.assistantSomethingWrong
        }
        
        // Single result - return formatted details
        return formatResultDetails(results[0])
    }
    
    // MARK: - Private Helper Methods - Response Generation
    
    /// Generates a news-like summary for multiple Olympic results
    /// - Parameter results: Olympic results to summarize
    /// - Returns: Generated summary string
    /// - Throws: ModelError if generation fails
    private func generateSummary(for results: [OlympicResult]) async throws -> String {
        guard isGeneralModelAvailable else {
            return AppStrings.assistantNotUnderstanding
        }
        
        generalSession = LanguageModelSession(
            instructions: AppStrings.summaryInstructions
        )
        
        // Extract key information from results for better prompting
        let eventDescriptions = results.map { result in
            let genderText = result.gender.map { "\($0)'s" } ?? ""
            return """
            \(result.sport) \(genderText) \(result.event):
            - Gold: \(result.goldMedalist.name) from \(result.goldMedalist.country)
            - Silver: \(result.silverMedalist.name) from \(result.silverMedalist.country)
            - Bronze: \(result.bronzeMedalist.name) from \(result.bronzeMedalist.country)
            """
        }.joined(separator: "\n\n")
        
        let prompt = """
        Write a brief, engaging news-style summary of these Olympic results. Make it read like a sports news article, not a data dump:
        
        \(eventDescriptions)
        
        Remember: Write in natural, flowing paragraphs. Use emojis for medals. Make it exciting!
        """
        
        do {
            let response = try await generalSession!.respond(
                to: prompt,
                generating: String.self
            )
            return response.content
            
        } catch {
            print("Summary generation error: \(error.localizedDescription)")
            throw ModelError.unknown
        }
    }
    
    /// Formats a single Olympic result into a readable string
    /// - Parameter result: The Olympic result to format
    /// - Returns: Formatted result string with medals and placements
    private func formatResultDetails(_ result: OlympicResult) -> String {
        var output = """
        🏊‍♀️ \(result.sport) \(result.event) Results:
        
        🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
        🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
        🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
        """
        
        // Add other finalists if available
        if let placements = result.placements, placements.count >= 2 {
            output += """
            
            
            Other finalists:
            4th: \(placements[0].name) (\(placements[0].country))
            5th: \(placements[1].name) (\(placements[1].country))
            """
        }
        
        return output
    }
    
    // MARK: - Private Helper Methods - Utility
    
    /// Creates a chat message from the assistant
    /// - Parameter content: The message content
    /// - Returns: A ChatMessage configured as an assistant response
    private func createChatMessage(content: String) -> ChatMessage {
        return ChatMessage(
            content: content,
            isUser: false,
            timestamp: Date()
        )
    }
}

