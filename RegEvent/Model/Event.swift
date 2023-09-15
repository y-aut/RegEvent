//
//  Event.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import Foundation

struct Event {
    var date: Date
    var startHour = 0
    var endHour = 0

    private var selectedHourValue = 0  // startHour, endHour を指定するときは -1
    var selectedHour: Int {
        get {
            return selectedHourValue
        }
        set(value) {
            selectedHourValue = value
            if (value >= 0) {
                startHour = Self.hours[value].0
                endHour = Self.hours[value].1
            }
        }
    }

    static let hours = [
        (8, 10), (10, 12), (12, 14), (14, 16), (16, 18), (18, 21)
    ]

    init(date: Date, selectedHour: Int) {
        self.date = date
        self.selectedHour = selectedHour
    }

    init(date: Date, startHour: Int, endHour: Int) {
        self.date = date
        selectedHour = -1
        self.startHour = startHour
        self.endHour = endHour
    }

    static func hourString(_ startHour: Int, _ endHour: Int) -> String {
        return "\(startHour > 12 ? startHour - 12 : startHour)-\(endHour > 12 ? endHour - 12 : endHour)"
    }
}
