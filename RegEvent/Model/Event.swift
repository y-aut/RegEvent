//
//  Event.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import Foundation

struct Event {
    var title: String
    var date: Date
    var startHour = 0
    var endHour = 0
    var location: Int
    var courtNumber = ""

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

    init(title: String, date: Date, selectedHour: Int, location: Int, courtNumber: String) {
        self.title = title
        self.date = date
        self.location = location
        self.courtNumber = courtNumber
        self.selectedHour = selectedHour
    }

    init(title: String, date: Date, startHour: Int, endHour: Int, location: Int, courtNumber: String) {
        self.title = title
        self.date = date
        self.location = location
        self.courtNumber = courtNumber
        selectedHour = -1
        self.startHour = startHour
        self.endHour = endHour
    }

    static func hourString(_ startHour: Int, _ endHour: Int) -> String {
        return "\(startHour > 12 ? startHour - 12 : startHour)－\(endHour > 12 ? endHour - 12 : endHour)"
    }

    func getLocation(modelData: ModelData) -> Location {
        guard let loc = modelData.locations.first(where: { $0.id == location }) else {
            fatalError("Couldn't find id \(location) in locations.")
        }
        return loc
    }

    func eventString(modelData: ModelData) -> String {
        var courtNumStr = ""
        if (!courtNumber.isEmpty) {
            courtNumStr += " "
            if (courtNumber.count == 1) {
                let num = Int(courtNumber)
                if (num != nil && 1 <= num! && num! <= 9) {
                    let circle = 0x2460
                    courtNumStr += String(UnicodeScalar(circle + num! - 1)!)
                } else if (courtNumber == "?") {
                    courtNumStr += "？"
                } else {
                    courtNumStr += courtNumber
                }
            }
            courtNumStr += "番コート"
        }
        return "\(title) \(getLocation(modelData: modelData).display)\(Self.hourString(startHour, endHour))\(courtNumStr)"
    }
}
