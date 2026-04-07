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
        description: "Set to true if the query is asking about a country's performance in swimming. Examples: 'how did Australia do', 'USA swimming results', 'Australia medals in swimming', 'what did Australia win'. Extract the country name or code if present."
    )
    let isCountryQuery: Bool
    
    @Guide(
        description: "The country name or code if the query is about a specific country's performance. Common codes: AUS (Australia), USA (United States), GBR (Great Britain). Leave empty if not a country query."
    )
    let countryCode: String?
}
