//
//  AthleteMedalTool.swift
//  la-olympics-2028
//
//  Created by Assistant on 3/26/26.
//

import Foundation
import FoundationModels

/// A custom tool for the Foundation Models framework that retrieves athlete medal information
/// This tool enables the LLM to query swimming athlete data and compare performance
struct AthleteMedalTool: Tool {
    typealias Output = String
    
    var description: String {
        """
        Retrieves Olympic swimming athlete medal information from a database of champion swimmers.
        
        Supports three search modes:
        1. Search by athlete name (searchType='athlete', athleteName='name')
        2. Search by country (searchType='country', countryCode='AUS')
        3. Get all athletes ranked by medals (searchType='all', limit=optional)
        
        Use this tool for questions about:
        - Individual athlete performance and medals
        - Country swimming performance and rankings
        - Comparing athletes or finding the best/top performers
        - Medal counts (gold, silver, bronze, total)
        
        Available data: Australian and USA Olympic swimming champions
        """
    }
    
    // MARK: - Tool Arguments
    
    /// Arguments structure that defines what parameters the LLM should provide
    @Generable
    struct Arguments: Codable {
        /// Search query type: "athlete", "country", or "all"
        @Guide(description: "Type of search to perform. Use 'athlete' to find a specific athlete by name, 'country' to get all athletes from a specific country, or 'all' to get all athletes ranked by medals (for 'who is the best' questions).")
        var searchType: String
        
        /// Name of athlete to search for (when searchType is "athlete")
        @Guide(description: "Name of the athlete to search for. Can be a partial name like 'McKeon' or full name like 'Emma McKeon'. ONLY provide this when searchType is 'athlete'. Leave nil for 'country' or 'all' searches.")
        var athleteName: String?
        
        /// Country code to filter by (when searchType is "country")
        @Guide(description: "Three-letter country code. REQUIRED when searchType is 'country'. Use: 'AUS' for Australia, 'USA' for United States, 'GBR' for Great Britain. Always use uppercase three-letter codes. Leave nil for 'athlete' or 'all' searches.")
        var countryCode: String?
        
        /// Maximum number of results to return for ranking queries
        @Guide(description: "Maximum number of results to return when using searchType 'all' or 'country'. For 'who is the best' questions, set to 1. For 'top 5 athletes', set to 5. For 'compare all athletes', set to 10 or omit (defaults to 10). Leave nil when searchType is 'athlete'.")
        var limit: Int?
    }
    
    // MARK: - Data Service
    
    private let dataService: AthleteMedalDataService
    
    // MARK: - Initialization
    
    init(dataService: AthleteMedalDataService = AthleteMedalDataService()) {
        self.dataService = dataService
    }
    
    // MARK: - Tool Protocol Implementation
    
    /// Executes the tool with provided arguments
    /// - Parameter arguments: The structured arguments from the LLM
    /// - Returns: A String with athlete medal information
    func call(arguments: Arguments) async throws -> String {
        print("🔧 Tool called with: \(arguments)")
        
        var foundAthletes: [SwimmingAthlete] = []
        
        // Handle different search types
        switch arguments.searchType.lowercased() {
        case "athlete":
            // Search for a specific athlete
            guard let athleteName = arguments.athleteName, !athleteName.isEmpty else {
                return "Error: athleteName is required when searchType is 'athlete'."
            }
            foundAthletes = dataService.findAthletes(byName: athleteName)
            
        case "country":
            // Get all athletes from a specific country
            guard let countryCode = arguments.countryCode, !countryCode.isEmpty else {
                return "Error: countryCode is required when searchType is 'country'."
            }
            foundAthletes = dataService.findAthletes(byCountry: countryCode)
            
        case "all":
            // Get all athletes for comparison
            foundAthletes = dataService.getAllAthletes()
            
        default:
            return "Error: searchType must be 'athlete', 'country', or 'all'."
        }
        
        // Handle no results
        guard !foundAthletes.isEmpty else {
            if let athleteName = arguments.athleteName {
                return "No athletes found with name: \(athleteName)"
            } else if let countryCode = arguments.countryCode {
                return "No athletes found for country code: \(countryCode)"
            }
            return "No athletes found."
        }
        
        // Sort by total medals (descending) for ranking
        foundAthletes.sort { $0.medalTotals.total > $1.medalTotals.total }
        
        // Apply limit if specified
        let limit = arguments.limit ?? 10
        if foundAthletes.count > limit {
            foundAthletes = Array(foundAthletes.prefix(limit))
        }
        
        // Return formatted info based on search type and number of athletes
        if arguments.searchType.lowercased() == "athlete" && foundAthletes.count == 1 {
            return formatAthleteDetails(foundAthletes[0])
        } else if arguments.searchType.lowercased() == "country" {
            return formatCountryAthletes(foundAthletes)
        } else {
            return formatRankedAthletes(foundAthletes)
        }
    }
    
    // MARK: - Formatting Methods
    
    /// Formats detailed information for a single athlete
    private func formatAthleteDetails(_ athlete: SwimmingAthlete) -> String {
        var response = """
        🏊 \(athlete.name.display) - Medal Information
        Country: \(athlete.country.name) (\(athlete.country.code))
        Sport: \(athlete.sports.first?.discipline ?? "Unknown")
        
        Career Medal Totals:
        🥇 Gold: \(athlete.medalTotals.gold)
        🥈 Silver: \(athlete.medalTotals.silver)
        🥉 Bronze: \(athlete.medalTotals.bronze)
        📊 Total: \(athlete.medalTotals.total) medals
        
        Olympic Appearances:
        
        """
        
        for appearance in athlete.olympicAppearances {
            response += """
            
            📅 \(appearance.year) - \(appearance.host)
            🥇 \(appearance.medals.gold) Gold | 🥈 \(appearance.medals.silver) Silver | 🥉 \(appearance.medals.bronze) Bronze
            
            Events:
            """
            
            for eventMedal in appearance.medals.detail {
                let emoji = medalEmoji(for: eventMedal.medal)
                response += "\n  \(emoji) \(eventMedal.event) - \(eventMedal.medal)"
            }
            
            response += "\n"
        }
        
        return response
    }
    
    /// Formats athletes from a specific country
    private func formatCountryAthletes(_ athletes: [SwimmingAthlete]) -> String {
        guard !athletes.isEmpty else {
            return "No athletes found."
        }
        
        let country = athletes[0].country
        let totalGold = athletes.reduce(0) { $0 + $1.medalTotals.gold }
        let totalSilver = athletes.reduce(0) { $0 + $1.medalTotals.silver }
        let totalBronze = athletes.reduce(0) { $0 + $1.medalTotals.bronze }
        let totalMedals = athletes.reduce(0) { $0 + $1.medalTotals.total }
        
        var response = """
        🏊 Swimming Athletes from \(country.name) (\(country.code))
        
        Country Medal Totals:
        🥇 Gold: \(totalGold)
        🥈 Silver: \(totalSilver)
        🥉 Bronze: \(totalBronze)
        📊 Total: \(totalMedals) medals
        
        Top Athletes:
        
        """
        
        for (index, athlete) in athletes.enumerated() {
            let rank = index + 1
            response += """
            \(rank). \(athlete.name.display)
               🥇 \(athlete.medalTotals.gold) | 🥈 \(athlete.medalTotals.silver) | 🥉 \(athlete.medalTotals.bronze) | 📊 Total: \(athlete.medalTotals.total)
            
            """
        }
        
        return response
    }
    
    /// Formats ranked athletes (for "all" search type)
    private func formatRankedAthletes(_ athletes: [SwimmingAthlete]) -> String {
        var response = "🏊 Top Swimming Athletes by Medal Count:\n\n"
        
        for (index, athlete) in athletes.enumerated() {
            let rank = index + 1
            response += """
            \(rank). \(athlete.name.display) (\(athlete.country.code))
               🥇 \(athlete.medalTotals.gold) | 🥈 \(athlete.medalTotals.silver) | 🥉 \(athlete.medalTotals.bronze) | 📊 Total: \(athlete.medalTotals.total)
            
            """
        }
        
        return response
    }
    
    /// Helper to get medal emoji
    private func medalEmoji(for medal: String) -> String {
        switch medal.lowercased() {
        case "gold": return "🥇"
        case "silver": return "🥈"
        case "bronze": return "🥉"
        default: return "🏅"
        }
    }
}

