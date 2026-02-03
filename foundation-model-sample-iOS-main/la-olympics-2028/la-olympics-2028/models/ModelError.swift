//
//  Untitled.swift
//  la-olympics-2028
//
//  Created by Goyal, Apurva on 8/14/25.
//

enum ModelError: Error {
    case network
    case invalidResponse
    case dataNotFound
    case unauthorized
    case unknown
    case notInitialized
    case modelNotAvailable
    case custom(message: String)

    var userMessage: String {
        switch self {
        case .network:
            return "Network error. Please check your connection and try again."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .dataNotFound:
            return "Sorry, no data was found for your request."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .unknown, .notInitialized:
            return "I am so sorry I am not able to help you. Please try again later."
        case .modelNotAvailable:
            return "I am so sorry but looks like you dont have access to the AI model . Please try again later."
        case .custom(let message):
            return message
        }
    }
}
