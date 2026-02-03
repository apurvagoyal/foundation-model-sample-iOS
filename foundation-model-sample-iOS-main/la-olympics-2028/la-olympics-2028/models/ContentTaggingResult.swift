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
}
