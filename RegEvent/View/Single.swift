//
//  Single.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI
import EventKit

struct Single: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EventTitle.calendar_id, ascending: true)],
        animation: .default)
    private var eventTitles: FetchedResults<EventTitle>
    
    @EnvironmentObject var modelData: ModelData

    @State var calendar: EKCalendar?
    @State private var event = Event()

    @State private var showAddAlert = false
    @State private var showAddErrorAlert = false
    @State private var showAddSuccessAlert = false

    var body: some View {
        VStack {
            ZStack {
                Text("イベントを作成")
                    .bold()
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    Button("追加") {
                        showAddAlert = true
                    }
                    .disabled(calendar == nil)
                    .alert("カレンダーに追加", isPresented: $showAddAlert) {
                        Button("キャンセル") {
                        }
                        Button("OK") {
                            do {
                                try modelData.eventManager.addEvent(event: event, calendar: calendar!, modelData: modelData)
                                showAddSuccessAlert = true
                                // EventTitle を保存
                                Util.addEventTitle(eventTitles: eventTitles, viewContext: viewContext, calendarId: calendar!.calendarIdentifier, name: event.title)
                            } catch {
                                print(error)
                                showAddErrorAlert = true
                            }
                        }
                    } message: {
                        Text("以下のイベントをカレンダーに追加してもよろしいですか？\n\n\(event.eventString(modelData: modelData))")
                    }
                    .alert("エラー", isPresented: $showAddErrorAlert) {
                        Button("OK") {}
                    } message: {
                        Text("カレンダーへのイベントの追加に失敗しました。")
                    }
                    .alert("完了", isPresented: $showAddSuccessAlert) {
                        Button("OK") {}
                    } message: {
                        Text("カレンダーにイベントを追加しました。")
                    }
                }
            }
            .padding([.top, .horizontal])

            EventEdit(calendar: $calendar, event: $event)
        }
    }
}

struct Single_Previews: PreviewProvider {
    static var previews: some View {
        Single()
            .environmentObject(ModelData())
    }
}
