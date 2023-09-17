//
//  EventEdit.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI
import EventKit
import CoreData

struct EventEdit: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EventTitle.calendar_id, ascending: true)],
        animation: .default)
    private var eventTitles: FetchedResults<EventTitle>

    @EnvironmentObject var modelData: ModelData
    @State private var hourPickerIndex = 0
    private static let courtNumberToggles = ["1", "2", "3", "4", "5", "?"]
    @State private var courtNumberToggleValue = [Bool](repeating: false, count: courtNumberToggles.count)

    var body: some View {
        List {
            Section {
                Picker("カレンダー", selection: $modelData.calendar) {
                    ForEach(modelData.eventManager.eventStore.calendars(for: .event), id: \.calendarIdentifier) { calendar in
                        if (calendar.allowsContentModifications) {
                            Text(calendar.title)
                                .tag(EKCalendar?.some(calendar))
                        }
                    }
                }
                .onChange(of: modelData.calendar) { value in
                    // タイトルを設定
                    if (value == nil) { return }
                    let item = eventTitles.first(where: { i in i.calendar_id == value!.calendarIdentifier })
                    if (item == nil || item!.name == nil) { return }
                    $modelData.event.title.wrappedValue = item!.name!
                }
            } footer: {
                if (!modelData.eventManager.eventStoreAuthorized()) {
                    Text("カレンダーへのアクセスが許可されていません。")
                }
            }

            HStack {
                Text("タイトル")
                TextField("入力", text: $modelData.event.title)
                    .multilineTextAlignment(TextAlignment.trailing)
            }

            DatePicker("日付", selection: $modelData.event.date, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "ja_JP"))

            Picker("時刻", selection: $hourPickerIndex) {
                ForEach(0 ..< Event.hours.count, id: \.self) { i in
                    Text(Event.hourString(Event.hours[i].0, Event.hours[i].1))
                }
                Text("カスタム").tag(-1)
            }
            .onChange(of: hourPickerIndex) { _ in
                withAnimation {
                    modelData.event.selectedHour = hourPickerIndex
                }
            }
            .pickerStyle(.inline)

            if (modelData.event.selectedHour == -1) {
                Section {
                    HStack {
                        Picker("開始時刻", selection: $modelData.event.startHour) {
                            ForEach(0 ..< 24, id: \.self) { i in
                                Text(String(i))
                            }
                        }
                        .onChange(of: modelData.event.startHour) { _ in
                            if (modelData.event.startHour >= modelData.event.endHour) {
                                withAnimation {
                                    modelData.event.endHour = modelData.event.startHour + 1
                                }
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                        
                        Text("－")
                        
                        Picker("終了時刻", selection: $modelData.event.endHour) {
                            ForEach(1 ... 24, id: \.self) { i in
                                Text(String(i))
                            }
                        }
                        .onChange(of: modelData.event.endHour) { _ in
                            if (modelData.event.startHour >= modelData.event.endHour) {
                                withAnimation {
                                    modelData.event.startHour = modelData.event.endHour - 1
                                }
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                    }
                }
                .padding(.vertical, -10)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.slide)
            }

            Picker("場所", selection: $modelData.event.location) {
                ForEach(modelData.locations) { location in
                    Text(location.short).tag(location.id)
                }
            }

            HStack {
                Text("コート番号")
                TextField("入力", text: $modelData.event.courtNumber)
                    .multilineTextAlignment(TextAlignment.trailing)
            }

            HStack {
                Spacer()

                ForEach(0 ..< Self.courtNumberToggles.count, id: \.self) { i in
                    Toggle(isOn: $courtNumberToggleValue[i]) {
                    }
                    .toggleStyle(CircleToggle(text: Self.courtNumberToggles[i]))
                    .onChange(of: courtNumberToggleValue[i]) { value in
                        if (value) {
                            for j in 0 ..< Self.courtNumberToggles.count {
                                if (i == j) { continue }
                                courtNumberToggleValue[j] = false
                            }
                            $modelData.event.courtNumber.wrappedValue = Self.courtNumberToggles[i]
                        } else if (courtNumberToggleValue.allSatisfy { b in !b }) {
                            $modelData.event.courtNumber.wrappedValue = ""
                        }
                    }
                }
            }
        }
        .disabled(!modelData.eventManager.eventStoreAuthorized())
    }
}

struct EventEdit_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.shared

        EventEdit()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(ModelData())
    }
}
