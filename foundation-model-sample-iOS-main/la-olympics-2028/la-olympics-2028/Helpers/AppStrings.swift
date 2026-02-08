import Foundation

struct AppStrings {
    // MARK: - Assistant Greetings & Prompts
    static let assistantGreeting = "Hello! I'm your Olympic assistant. Ask me about Olympic schedules, statistics, or game rules!"
    static let assistantConfused = "Hmm I am confused. Please try again later."
    static let assistantBusy = "Assistant is busy. Please try again later."
    static let assistantUnavailable = "Cannot find any assistant. Please try again later."
    static let assistantGenericPrompt = "Okay! What else can I tell you about Olympics"
    static let assistantAskAnything = "I am sorry! I can only help you with any information on Olympics"
    static let assistantNoSpecificResults = "I was not able to get specific result for you, can you be more specific?"
    static let assistantGenericError = "Hmm something went wrong. Please try again later."
    static let assistantNoModel = "I am so sorry but looks like you dont have access to the AI model . Please try again later."
    static let assistantUnknownError = "I am so sorry I am not able to help you. Please try again later."
    static let assistantCannotFindFile = "Could not find olympicsschedule.json file"
    static let assistantSomethingWrong = "Something wrong happened"
    static let assistantNotUnderstanding = "I am not able to understand your question. Lets try again"
    //static let assistantClassifyPrompt =     

    // MARK: - Model Instructions & Content
//    static let contentTaggingInstructions = """
//    Provide a few tags that brings out the exact sports event and its category like men's or mixed doubles in user query.
//    """
    
    static let contentTaggingInstructions = """
    Find tags related to sport, event like singles or double and gender.
    """

    static let summaryInstructions = """
    You are a sports news writer for the Olympics. Your job is to create engaging, human-readable summaries of Olympic event results.
    
    Guidelines:
    - Write in a natural, conversational style like a news article
    - Start with an overview of the events being summarized
    - Highlight winners and their countries with emojis (🥇 🥈 🥉)
    - Use engaging language and avoid technical jargon
    - Format as flowing paragraphs, NOT as JSON or structured data
    - Make it exciting and celebratory
    - Keep it concise but informative
    """
    
    static let contentSearchInstructions = """
    Your job is to first summarize the data in a way that provides unique sports events with gender and then search for specific events
    """
    
    static let modelInstructions = """
    You are a friendly olympics assistant. Your job is to provide right answers to only things related to sporting events in olympics
    """
    
    static let eventMatchingInstructions = """
    You are an expert in Olympic sports terminology and event naming conventions. Your job is to understand user queries and match them to the exact event names used in Olympic data.
    
    Key responsibilities:
    - Understand common variations (e.g., "100 meters" = "100m", "freestyle" = specific freestyle events)
    - Match informal terms to official Olympic event names
    - Handle abbreviations, full names, and colloquial terms
    - Consider context from sport type and gender when matching
    - Provide the most accurate match from available events
    
    Common patterns:
    - Distances: "100 meters" → "100m", "4x100 relay" → "4x100m Relay"
    - Swimming strokes: "freestyle", "butterfly", "backstroke", "breaststroke", "medley"
    - Event types: "singles", "doubles", "mixed doubles", "team", "individual"
    - Abbreviations: "m" for meters, "km" for kilometers
    """

//    static let promptNextQuestion = "Generate a textual and user friendly reply as a prompt for asking next question after answering first question"
    
    static let promptNextQuestion = "Generate a dialog asking next question after answering first question around olympic stats"
    static let quizQuestion = "Quiz me about Olympics"
    // MARK: - Formatting Templates
    static func eventResult(sport: String, event: String, gold: String, goldCountry: String, silver: String, silverCountry: String, bronze: String, bronzeCountry: String, placements: [(String, String)]? = nil) -> String {
        var result = """
        🏊‍♀️ \(sport) \(event) Results:

        🥇 Gold: \(gold) (\(goldCountry))
        🥈 Silver: \(silver) (\(silverCountry))
        🥉 Bronze: \(bronze) (\(bronzeCountry))
        """

        if let placements = placements, placements.count >= 2 {
            result += """

            Other finalists:
            4th: \(placements[0].0) (\(placements[0].1))
            5th: \(placements[1].0) (\(placements[1].1))
            """
        }
        return result
    }
}
