//
//  EventValidationResult.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/10/03.
//

import Foundation

// イベント文字列をパースした結果を表す
struct EventValidationResult {
    var result: Result
    var event: Event?
    var message: String?

    enum Result {
        case Success
        case Warning
        case Error
        case Unparsed
    }

    private init(result: Result, event: Event?, message: String?) {
        self.result = result
        self.event = event
        self.message = message
    }

    static func success(_ event: Event) -> EventValidationResult {
        return EventValidationResult(result: .Success, event: event, message: nil)
    }

    static func warning(event: Event, message: String) -> EventValidationResult {
        return EventValidationResult(result: .Warning, event: event, message: message)
    }

    static func error(_ message: String) -> EventValidationResult {
        return EventValidationResult(result: .Error, event: nil, message: message)
    }

    static func unparsed() -> EventValidationResult {
        return EventValidationResult(result: .Unparsed, event: nil, message: nil)
    }

    func toString(modelData: ModelData) -> String {
        return message ?? event!.eventStringWithoutTitle(modelData: modelData)
    }
}
