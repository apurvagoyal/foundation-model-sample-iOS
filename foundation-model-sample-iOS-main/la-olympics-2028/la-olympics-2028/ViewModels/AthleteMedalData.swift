//
//  AthleteMedalData.swift
//  la-olympics-2028
//
//  Created by Assistant on 3/26/26.
//

import Foundation

// MARK: - Athlete Models

struct SwimmingAthlete: Codable {
    let id: String
    let name: AthleteName
    let country: AthleteCountry
    let sports: [AthleteSport]
    let olympicAppearances: [OlympicAppearance]
    let medalTotals: MedalTotals
}

struct AthleteName: Codable {
    let full: String
    let display: String
}

struct AthleteCountry: Codable {
    let code: String
    let name: String
}

struct AthleteSport: Codable {
    let name: String
    let discipline: String
    let events: [String]
}

struct OlympicAppearance: Codable {
    let year: Int
    let host: String
    let season: String
    let medals: MedalDetails
}

struct MedalDetails: Codable {
    let gold: Int
    let silver: Int
    let bronze: Int
    let detail: [EventMedal]
}

struct EventMedal: Codable {
    let event: String
    let medal: String
}

struct MedalTotals: Codable {
    let gold: Int
    let silver: Int
    let bronze: Int
    let total: Int
}

// MARK: - Data Service

class AthleteMedalDataService {
    
    private var athletes: [SwimmingAthlete] = []
    
    init() {
        loadAthleteData()
    }
    
    /// Loads athlete data from the JSON file
    private func loadAthleteData() {
        guard let url = Bundle.main.url(forResource: "athletedata", withExtension: "json") else {
            print("Could not find athletedata.json file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            athletes = try decoder.decode([SwimmingAthlete].self, from: data)
            print("✅ Successfully loaded \(athletes.count) athletes")
        } catch {
            print("❌ Error loading athlete JSON data: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves all athletes
    func getAllAthletes() -> [SwimmingAthlete] {
        return athletes
    }
    
    /// Finds athletes by name (partial match)
    func findAthletes(byName name: String) -> [SwimmingAthlete] {
        let searchTerm = name.lowercased()
        return athletes.filter { athlete in
            athlete.name.full.lowercased().contains(searchTerm) ||
            athlete.name.display.lowercased().contains(searchTerm)
        }
    }
    
    /// Finds athletes by country code
    func findAthletes(byCountry countryCode: String) -> [SwimmingAthlete] {
        let code = countryCode.uppercased()
        return athletes.filter { $0.country.code == code }
    }
    
    /// Finds athletes by sport/discipline
    func findAthletes(bySport sport: String) -> [SwimmingAthlete] {
        let searchTerm = sport.lowercased()
        return athletes.filter { athlete in
            athlete.sports.contains { athleteSport in
                athleteSport.name.lowercased().contains(searchTerm) ||
                athleteSport.discipline.lowercased().contains(searchTerm)
            }
        }
    }
    
    /// Gets an athlete by their unique ID
    func getAthlete(byId id: String) -> SwimmingAthlete? {
        return athletes.first { $0.id == id }
    }
}
