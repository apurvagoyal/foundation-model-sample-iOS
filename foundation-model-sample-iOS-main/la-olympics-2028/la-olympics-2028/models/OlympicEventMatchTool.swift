//
//  FindEventResultTool.swift
//  la-olympics-2028
//
//  Created by Goyal, Apurva on 8/18/25.
//

import Foundation
import FoundationModels

final class OlympicEventMatchTool {
    let name = "findOlympicsEventResult"
    let description = "Suggests the Olympics events that user can attend based on their calendar"
//    
//    @Generable
//    struct Arguments {
//        @Guide(description: "Date from which to search for events in user's calendar")
//        let from: Date
//        @Guide(description: "Date till which to search for events in user's calendar")
//        let to: Date
//    }
//    
//    func call(arguments: Arguments) async -> [EKEvent] {
//        //get the
//        let results = getDataUsingTags(arguments: arguments)
//        if results.isEmpty {
//            return " "
//        }
//        
//        return results
//    }
//    
//    @MainActor func olympicEventsFor(duration: Int) -> [OlympicEvent] {
//        //find the events in the calendar for the given duration
//
//        
//    }
    
//    func call(keywords: [String], gender: [String]) async -> String {
//        
//        //let results = getData(arguments: arguments)
//        let results = getDataUsingTags(keywords: keywords, gender: gender)
//        if results.isEmpty {
//            return " "
//        }
//        
//        return results
//    }
    
//    private func getData(arguments: Arguments) -> String{
//        guard let url = Bundle.main.url(forResource: "olympicsdata", withExtension: "json") else {
//            print("Could not find olympicsschedule.json file")
//            return "Could not find olympicsschedule.json file"
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let decoder = JSONDecoder()
//            let results = try decoder.decode([OlympicResult].self, from: data)
//            
//            //return results.filter { ($0.sport.lowercased() + $0.event.lowercased()) .contains(arguments.query.lowercased())}
//            
//            let filteredResults = results.filter { result in
//                guard let gender = result.gender else {
//                    // 1
//                    return
//                        (arguments.query.lowercased().contains (result.sport.lowercased()) &&
//                        arguments.query.lowercased().contains (result.event.lowercased()))
//                }
//                    
//                return
//                    (arguments.query.lowercased().contains (result.sport.lowercased()) &&
//                    arguments.query.lowercased().contains (result.event.lowercased()) &&
//                     arguments.query.lowercased().contains (gender.lowercased()))
//
//                
//            }
//            
//         
//            guard let firstResult = filteredResults.first else {
//                return "Sorry I cannot find that for you"
//            }
//            return """
//                    🏊‍♀️ \(firstResult.sport) \(firstResult.event) Results:
//                    
//                    🥇 Gold: \(firstResult.goldMedalist.name) (\(firstResult.goldMedalist.country))
//                    🥈 Silver: \(firstResult.silverMedalist.name) (\(firstResult.silverMedalist.country))
//                    🥉 Bronze: \(firstResult.bronzeMedalist.name) (\(firstResult.bronzeMedalist.country))
//                    
//                    Other finalists:
//                    4th: \(firstResult.placements?[0].name) (\(firstResult.placements?[0].country))
//                    5th: \(firstResult.placements?[1].name) (\(firstResult.placements?[1].country))
//                    """
//           
//    
//            //return results
//        } catch {
//            print("Error loading JSON data: \(error)")
//            return "Something wrong happened"
//        }
//    }

    

}
