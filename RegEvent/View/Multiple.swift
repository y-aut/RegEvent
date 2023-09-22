//
//  Multiple.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/21.
//

import SwiftUI
import EventKit

struct Multiple: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EventTitle.calendar_id, ascending: true)],
        animation: .default)
    private var eventTitles: FetchedResults<EventTitle>
    
    @EnvironmentObject var modelData: ModelData

    @State var calendar: EKCalendar?
    @State private var text: String = ""
    @State private var lines: [(String, EventValidationResult)] = []
    @State private var events: [Event] = []
    @State private var title: String = ""

    @State private var editorPresented = false
    @State private var showAddAlert = false
    @State private var showAddErrorAlert = false
    @State private var showAddSuccessAlert = false

    var body: some View {
        VStack {
            ZStack {
                Text("イベントを一括登録")
                    .bold()
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    Button("追加") {
                        showAddAlert = true
                    }
                    .disabled(events.isEmpty || calendar == nil)
                    .alert("カレンダーに追加", isPresented: $showAddAlert) {
                        Button("キャンセル") {
                        }
                        Button("OK") {
                            do {
                                for i in 0 ..< events.count {
                                    events[i].title = title
                                    try modelData.eventManager.addEvent(event: events[i], calendar: calendar!, modelData: modelData)
                                }
                                showAddSuccessAlert = true
                                // EventTitle を保存
                                Util.addEventTitle(eventTitles: eventTitles, viewContext: viewContext, calendarId: calendar!.calendarIdentifier, name: title)
                            } catch {
                                print(error)
                                showAddErrorAlert = true
                            }
                        }
                    } message: {
                        Text("\(events.count) 件のイベントをカレンダーに追加してもよろしいですか？")
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

            List {
                Section {
                    Picker("カレンダー", selection: $calendar) {
                        ForEach(modelData.eventManager.eventStore.calendars(for: .event), id: \.calendarIdentifier) { calendar in
                            if (calendar.allowsContentModifications) {
                                Text(calendar.title)
                                    .tag(EKCalendar?.some(calendar))
                            }
                        }
                    }
                    .onChange(of: calendar) { value in
                        // タイトルを設定
                        if (value == nil) { return }
                        let item = eventTitles.first(where: { i in i.calendar_id == value!.calendarIdentifier })
                        if (item == nil || item!.name == nil) { return }
                        title = item!.name!
                    }
                } footer: {
                    if (!modelData.eventManager.eventStoreAuthorized()) {
                        Text("カレンダーへのアクセスが許可されていません。")
                    }
                }

                HStack {
                    Text("タイトル")
                    TextField("入力", text: $title)
                        .multilineTextAlignment(TextAlignment.trailing)
                }

                Section {
                    Button {
                        editorPresented = true
                    } label: {
                        if (lines.isEmpty) {
                            Text("イベントテキストを入力")
                        } else {
                            Text("イベントテキストを編集")
                        }
                    }
                    .fullScreenCover(isPresented: $editorPresented) {
                        EventText(text: $text, lines: $lines, events: $events)
                    }

                    ForEach(0 ..< lines.count, id: \.self) { i in
                        GeometryReader { geo in
                            ZStack {
                                Text(lines[i].0)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                if (lines[i].1.result != .Unparsed) {
                                    HStack {
                                        Spacer()
                                        EventValidation(result: lines[i].1, maxWidth: geo.size.width * 0.6)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .disabled(!modelData.eventManager.eventStoreAuthorized())
    }
}

struct Multiple_Previews: PreviewProvider {
    static var previews: some View {
        Multiple()
            .environmentObject(ModelData())
    }
}
