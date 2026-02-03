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
    var results: [OlympicResult] = []
 
    //private var model = SystemLanguageModel.default
    private var model = SystemLanguageModel(useCase: .contentTagging)
    private var generalModel = SystemLanguageModel(useCase: .general)
    private var session: LanguageModelSession?
    private var genericSession: LanguageModelSession?
    var isModelInitialized: Bool {
        model.availability == .available
    }
    
    var isGenericModelInitialized: Bool {
        generalModel.availability == .available
    }
    //let tools: [any Tool] = [FindOlympicsEventResultTool()]
    
    func getInitialMessage() -> ChatMessage {
        if isModelInitialized {
            session = LanguageModelSession(
                instructions:  AppStrings.contentTaggingInstructions)
            
            // Welcome message
            return ChatMessage(
                content: AppStrings.assistantGreeting,
                isUser: false,
                timestamp: Date()
            )
            
        } else {
            return ChatMessage(
                content: ModelError.modelNotAvailable.localizedDescription,
                isUser: false,
                timestamp: Date()
            )
        }
    }
    
    func preWarm(){
        
    }
    
    private func getContentTags(query: String) async throws -> ContentTaggingResult {
        do {
            let response = try await session!.respond(
                to: query,
                generating: ContentTaggingResult.self
            )
            return response.content
        }
        catch (let error) {
            print(error.localizedDescription)
            throw ModelError.unknown
        }
    }
  
    func query(query: String) async  -> ChatMessage {
        guard let session = session else {
            return generateChatMessage(message: AppStrings.assistantUnavailable)
        }
        guard !session.isResponding else {
            return generateChatMessage(message: AppStrings.assistantBusy)
        }
        do {
            let queryTags = try await getContentTags(query: query)
            guard  !queryTags.topics.isEmpty else {
                return generateChatMessage(message: AppStrings.assistantSomethingWrong)
            }
            
            let response = await processQuery(keywords: queryTags.topics, gender: queryTags.gender)
            let assistantMessage = ChatMessage(
                content: response,
                isUser: false,
                timestamp: Date()
            )
            return assistantMessage
        }
        catch (let err) {
            print (err.localizedDescription)
            return generateChatMessage(message: AppStrings.assistantSomethingWrong)
        }
    }
    
    func generateChatMessage(message: String) -> ChatMessage {
        return ChatMessage(
            content: message,
            isUser: false,
            timestamp: Date()
        )
    }
    
    func questionCategory(message: String) async -> Category {
        if isGenericModelInitialized {
            genericSession = LanguageModelSession(instructions: AppStrings.modelInstructions)
            do {
                let response = try await genericSession!.respond(
                    to: "Classify \(message) into one of the following categories - question about rules of a sport, question about a sporting event result or others",
                    generating: Category.self
                )
                return response.content
            }
            catch (let error) {
                print(error.localizedDescription)
                return Category(questionCategory: .other)
            }
        } else {
            return Category(questionCategory: .other)
        }
    }
    
    func generateContent(prompt: String) async throws -> String {
        if isGenericModelInitialized {
            genericSession = LanguageModelSession()
            do {
                let response = try await genericSession!.respond(
                    to: prompt,
                    generating: Prompt.self
                )
                return response.content.response
            }
            catch (let error) {
                print(error.localizedDescription)
                return AppStrings.assistantGenericError
            }
        } else {
            return AppStrings.assistantUnavailable
        }
    }
    
    private func generateSummary(data: [OlympicResult]) async throws -> String {
        if isGenericModelInitialized {
            genericSession = LanguageModelSession(
                instructions:  AppStrings.summaryInstructions)
            do {
                let response = try await genericSession!.respond(
                    to: "generate a textual and user friendly news like summary of this data \(data)",
                    generating: String.self
                )
                return response.content
            }
            catch (let error) {
                print(error.localizedDescription)
                throw ModelError.unknown
            }
        } else {
            return AppStrings.assistantNotUnderstanding
        }
    }
    
//    private func checkOlympicsData(data: String, keywords: [String], gender: [String]) async throws -> [OlympicResult] {
//        guard isGenericModelInitialized else {
//            throw ModelError.notInitialized
//        }
//        genericSession = LanguageModelSession()
//        do {
//            let response = try await genericSession!.respond(
//                to: "find all the events from \(data) that matches all of the \(keywords) and \(gender)",
//                generating: [OlympicResult].self
//            )
//            return response.content
//        }
//        catch (let error) {
//            print(error.localizedDescription)
//            throw ModelError.unknown
//        }
//    }
    
    private func matchAllKeywords(data: [OlympicResult], keywords: [String]) async throws -> [OlympicResult] {
        guard !data.isEmpty else {
            return []
        }
        
        guard isGenericModelInitialized else {
            return []
        }
        
            genericSession = LanguageModelSession(
                instructions:  AppStrings.contentSearchInstructions)
            //
            do {
                let response = try await genericSession!.respond(
                    to: "find all events in \(data) where \(data.map{$0.event}) contains most of the \(keywords)",
                    generating: [OlympicResult].self
                )
                return response.content
            }
            catch (let error) {
                print(error.localizedDescription)
                throw ModelError.unknown
            }
        
    }

    // --- EXTRACTED FUNCTION ---
    func generateStringResponse(for result: OlympicResult) -> String {
        if let placements = result.placements, !placements.isEmpty {
            return """
                🏊‍♀️ \(result.sport) \(result.event) Results:

                🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
                🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
                🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))

                Other finalists:
                4th: \(placements[0].name) (\(placements[0].country))
                5th: \(placements[1].name) (\(placements[1].country))
                """
        } else {
            return """
                🏊‍♀️ \(result.sport) \(result.event) Results:
                🥇 Gold: \(result.goldMedalist.name) (\(result.goldMedalist.country))
                🥈 Silver: \(result.silverMedalist.name) (\(result.silverMedalist.country))
                🥉 Bronze: \(result.bronzeMedalist.name) (\(result.bronzeMedalist.country))
                """
        }
    }

    private func processQuery(keywords: [String], gender: [String]) async -> String {
        guard let url = Bundle.main.url(forResource: "olympicsdata", withExtension: "json") else {
            print("Could not find olympicsschedule.json file")
            return AppStrings.assistantCannotFindFile
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let results = try decoder.decode([OlympicResult].self, from: data)
            
            // make all values lowercase
            let keywords_lowercased = keywords.map { $0.lowercased() }
            
            let filteredResults = results.filter { result in
                let fields = [result.sport, result.event].map { $0.lowercased() }
                return keywords_lowercased.contains { keyword in
                    fields.contains(where: { field in keyword.contains(field) })
                }
            }
            
            guard !filteredResults.isEmpty else {
                return AppStrings.assistantNoSpecificResults
            }
            
            var sportsWithGender: [OlympicResult] = []
            if !gender.isEmpty {
                let resultsWithGender = filteredResults.filter { $0.gender != nil }
                if !resultsWithGender.isEmpty {
                    sportsWithGender = resultsWithGender.filter { $0.gender!.lowercased() == gender[0].lowercased() }
                }
            }
            
            guard !sportsWithGender.isEmpty else {
                return AppStrings.assistantNoSpecificResults
            }
            
            guard sportsWithGender.count == 1 else {
                return try await generateSummary(data: sportsWithGender)
//                let matchingResults = try await matchAllKeywords(data: sportsWithGender, keywords: keywords)
//                
//                if matchingResults.count == 1 {
//                    return generateStringResponse(for: matchingResults[0])
//                }
//                else {
//                    return try await generateSummary(data: sportsWithGender)
//                }
            }
            // If exactly one result, return its formatted string
            return generateStringResponse(for: sportsWithGender[0])
        } catch (let error) {
            print("Error loading JSON data: \(error)")
            return "Something wrong happened"
        }
    }
}
