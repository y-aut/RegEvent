//
//  ModelData.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import Foundation
import EventKit

final class ModelData: ObservableObject {
    @Published var event = Event(title: "", date: Date(), selectedHour: 0, location: 0, courtNumber: "")
    @Published var calendar: EKCalendar? = nil
    @Published var eventManager = EventManager()
    var locations: [Location] = load("locationData.json")

    func getCalendar() {
        _ = eventManager.confirmEventStoreAuth()
        calendar = eventManager.eventStore.defaultCalendarForNewEvents
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
