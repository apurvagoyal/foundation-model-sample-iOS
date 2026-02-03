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
    Generate a textual and user friendly news like summary of all the sport events and their results where events match closest to user query.
    """
    
    static let contentSearchInstructions = """
    Your job is to first summarize the data in a way that provides unique sports events with gender and then search for specific events
    """
    
    static let modelInstructions = """
    You are a friendly olympics assistant. Your job is to provide right answers to only things related to sporting events in olympics
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
