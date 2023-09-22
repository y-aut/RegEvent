//
//  EventManager.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/16.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    var eventStore = EKEventStore()
    @Published private var authorized = false

    init() {
        _ = eventStoreAuthorized()
    }

    func eventStoreAuthorized() -> Bool {
        authorized = EKEventStore.authorizationStatus(for: .event) == .authorized
        return authorized
    }

    func confirmEventStoreAuth() -> Bool {
        if (EKEventStore.authorizationStatus(for: .event) == .notDetermined) {
            eventStore.requestAccess(to: .event) { granted, error in
                if let error = error {
                    debugPrint(error.localizedDescription)
                } else {
                    debugPrint("EKEventStore.authorizationStatus: \(granted)")
                }
            }
        }
        return eventStoreAuthorized()
    }

    func addEvent(event: Event, calendar: EKCalendar, modelData: ModelData) throws {
        let startDate = event.date.setHour(hour: event.startHour)
        let endDate = event.date.setHour(hour: event.endHour)

        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = event.eventString(modelData: modelData)
        ekEvent.startDate = startDate
        ekEvent.endDate = endDate
        ekEvent.location = event.getLocation(modelData: modelData).name
        ekEvent.calendar = calendar
        try eventStore.save(ekEvent, span: .thisEvent)
    }
}
