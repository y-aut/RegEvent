//
//  Util.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/16.
//

import Foundation
import SwiftUI
import CoreData

class Util {
    static func addEventTitle(eventTitles: FetchedResults<EventTitle>, viewContext: NSManagedObjectContext, calendarId: String, name: String) {
        var item = eventTitles.first(where: { i in i.calendar_id == calendarId })
        if (item == nil) {
            item = EventTitle(context: viewContext)
            item!.calendar_id = calendarId
        }
        item!.name = name

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension String {
    // 全角->半角(英数字)
    func toNarrow() -> String {
        var res = ""
        for c in self.unicodeScalars {
            if (c == "　") { res += " " }
            if (0xff01 <= c.value && c.value <= 0xff5e) {
                if let convertedScalar = UnicodeScalar(c.value - 0xfee0) {
                    res.unicodeScalars.append(convertedScalar)
                }
            } else {
                res.unicodeScalars.append(c)
            }
        }
        return res
    }
}

extension Date {
    // 日付と時刻を設定する
    func setDate(month: Int, day: Int, hour: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let res = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: self),
            month: month,
            day: day,
            hour: hour,
            minute: 0,
            second: 0,
            nanosecond: 0
        ))
        return res!
    }

    // 年を進める
    func addYear(year: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let res = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: self) + year,
            month: calendar.component(.month, from: self),
            day: calendar.component(.day, from: self),
            hour: calendar.component(.hour, from: self),
            minute: 0,
            second: 0,
            nanosecond: 0
        ))
        return res!
    }

    // 月を進める
    func addMonth(month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let res = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: self),
            month: calendar.component(.month, from: self) + month,
            day: calendar.component(.day, from: self),
            hour: calendar.component(.hour, from: self),
            minute: 0,
            second: 0,
            nanosecond: 0
        ))
        return res!
    }

    // 時刻を設定する
    func setHour(hour: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let res = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: self),
            month: calendar.component(.month, from: self),
            day: calendar.component(.day, from: self),
            hour: hour,
            minute: 0,
            second: 0,
            nanosecond: 0
        ))
        return res!
    }
}
