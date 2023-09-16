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

    func addEvent(modelData: ModelData) throws {
        let startDate = Util.setHour(date: modelData.event.date, hour: modelData.event.startHour)
        let endDate = Util.setHour(date: modelData.event.date, hour: modelData.event.endHour)

        let event = EKEvent(eventStore: eventStore)
        event.title = modelData.event.eventString(modelData: modelData)
        event.startDate = startDate
        event.endDate = endDate
        event.location = modelData.event.getLocation(modelData: modelData).name
        event.calendar = modelData.calendar
        try eventStore.save(event, span: .thisEvent)
    }
}
