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

    init() {
        self.title = ""
        self.date = Date()
        self.location = 0
        self.courtNumber = ""
        self.selectedHour = 0
    }

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

    func eventStringWithoutTitle(modelData: ModelData) -> String {
        var courtNumStr = courtNumber
        if (!courtNumber.isEmpty) {
            if (courtNumber.count == 1) {
                let num = Int(courtNumber)
                if (num != nil && 1 <= num! && num! <= 9) {
                    let circle = 0x2460
                    courtNumStr = String(UnicodeScalar(circle + num! - 1)!)
                } else if (courtNumber == "?") {
                    courtNumStr = "？"
                }
            }
            courtNumStr = " " + courtNumStr + "番コート"
        }
        return "\(getLocation(modelData: modelData).display)\(Self.hourString(startHour, endHour))\(courtNumStr)"
    }

    func eventString(modelData: ModelData) -> String {
        return "\(title) \(eventStringWithoutTitle(modelData: modelData))"
    }

    // イベント文字列をパースする
    static func parse(_ text: String, modelData: ModelData) -> EventValidationResult {
        var warning = ""
        var str = text.toNarrow()

        // 日付を抽出する
        guard let dateText = str.firstMatch(of: /([01]?\d)\/([0123]?\d)/) else {
            return .unparsed()
        }
        let month = Int(dateText.1)!
        let day = Int(dateText.2)!

        // 以降のマッチは日付の後ろから行う
        str = String(str[dateText.range.upperBound...])

        // 時刻を抽出する
        guard let timeText = str.firstMatch(of: /([012]?\d)-([012]?\d)/) else {
            return .unparsed()
        }
        var startTime = Int(timeText.1)!
        var endTime = Int(timeText.2)!

        // 午前・午後を明示しているか
        var startExplicit = false, endExplicit = false;
        // 06 など 0 が入っていれば午前と解釈する
        if (timeText.1.first! != "0") {
            // 7 以下なら午後
            if (startTime <= 7) {
                startTime += 12;
            } else if (startTime > 12) {
                startExplicit = true;
            }
        } else {
            startExplicit = true;
        }
        if (timeText.2.first! != "0") {
            // 9 以下なら午後
            if (endTime <= 9) {
                endTime += 12;
            } else if (endTime > 12) {
                endExplicit = true;
            }
        } else {
            endExplicit = true;
        }

        if (startTime >= endTime) {
            // 開始時刻は午前，終了時刻は午後と解釈
            if (startExplicit && endExplicit) {
                return .error("開始時刻は終了時刻よりも前である必要があります")
            }
            if (startExplicit) {
                if (endTime < 12) {
                    endTime += 12;
                }
                if (startTime >= endTime) {
                    return .error("開始時刻は終了時刻よりも前である必要があります")
                }
            } else if (endExplicit) {
                if (startTime >= 12) {
                    startTime -= 12;
                }
                if (startTime >= endTime) {
                    return .error("開始時刻は終了時刻よりも前である必要があります")
                }
            } else {
                if (startTime >= 12) {
                    startTime -= 12;
                }
                if (startTime >= endTime) {
                    if (endTime < 12) {
                        endTime += 12;
                    }
                    if (startTime >= endTime) {
                        return .error("開始時刻は終了時刻よりも前である必要があります")
                    }
                }
            }
        }

        let now = Date()
        var date = now.setDate(month: month, day: day, hour: startTime)

        // [-3m, 9m] の範囲に収まるようにする
        var date2 = now.addMonth(month: -3)
        if (date < date2) {
            date = date.addYear(year: 1)
        } else {
            date2 = now.addMonth(month: 9)
            if (date > date2) {
                date = date.addYear(year: -1)
            }
        }

        // 曜日を抽出する
        if let dayText = str.firstMatch(of: /\(([日月火水木金土])\)/) {
            let WEEKDAY = "日月火水木金土"
            let weekday = WEEKDAY.firstIndex(of: dayText.1.first!)!.utf16Offset(in: WEEKDAY) + 1
            let calendar = Calendar(identifier: .gregorian)
            if (weekday != calendar.component(.weekday, from: date)) {
                warning = "\(calendar.component(.year, from: date))年" +
                "\(calendar.component(.month, from: date))月" +
                "\(calendar.component(.day, from: date))日" +
                "は\(dayText.1)曜日ではありません"
            }
        }

        // コート番号を抽出する
        var number = "？"
        if let numberText = str.firstMatch(of: /[\u{2460}-\u{2473}]/) {
            number = String(numberText.0)
        } else if let numberText = str.firstMatch(of: /\((\d{1,2})\)/) {
            number = String(numberText.1)
        }

        // 場所を抽出する
        guard let location = modelData.locations.first(where: { str.contains($0.match) }) else {
            return .error("不明なコートです")
        }

        let event = Event(title: "", date: date, startHour: startTime, endHour: endTime,
                          location: location.id, courtNumber: number)
        return warning.isEmpty ? .success(event) : .warning(event: event, message: warning)
    }
}
