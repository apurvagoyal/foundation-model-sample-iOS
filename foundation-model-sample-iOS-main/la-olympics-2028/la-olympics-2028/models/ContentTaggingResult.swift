//
//  ContentTaggingResult.swift
//  la-olympics-2028
//
//  Created by Goyal, Apurva on 8/30/25.
//

import Foundation
import FoundationModels

@Generable
struct ContentTaggingResult {
    @Guide(
        description: "Most important sports related key points in the input text.",
        .maximumCount(2)
    )
    let topics: [String]
    
    @Guide(
        description: "Gender in the input text."
    )
    let gender: [String]
    
    @Guide(
        description: "Set to true if the query is asking about athlete comparison or determining the best athlete. Examples: 'who is better', 'who is the best', 'compare athletes', 'who won more medals'."
    )
    let isAthleteComparison: Bool
    
    @Guide(
        description: "Set to true if the query is asking about a country's performance in swimming. Examples: 'how did Australia do', 'USA swimming results', 'Australia medals in swimming', 'what did Australia win', 'Australia's performance'. Look for country names like Australia, USA, United States, America, Britain, etc."
    )
    let isCountryQuery: Bool
    
    @Guide(
        description: "Extract the country mentioned in the query. Return either the full country name (e.g., 'Australia', 'United States') OR the three-letter code (e.g., 'AUS', 'USA'). If the query mentions 'Australia' or 'AUS', return 'Australia'. If the query mentions 'USA', 'United States', or 'America', return 'United States'. Only populate this when isCountryQuery is true."
    )
    let countryCode: String?
}
