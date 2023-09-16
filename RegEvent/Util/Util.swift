//
//  Util.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/16.
//

import Foundation

class Util {
    // 時刻を設定する
    static func setHour(date: Date, hour: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let res = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: hour,
            minute: 0,
            second: 0,
            nanosecond: 0
        ))
        return res!
    }
}
