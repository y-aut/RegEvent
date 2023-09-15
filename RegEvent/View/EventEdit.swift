//
//  EventEdit.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct EventEdit: View {
    @EnvironmentObject var modelData: ModelData
    @Binding var event: Event
    @State private var hourPickerIndex = 0

    var body: some View {
        List {
            HStack {
                Text("タイトル")
                TextField("入力", text: $event.title)
                    .multilineTextAlignment(TextAlignment.trailing)
            }

            DatePicker("日付", selection: $event.date, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "ja_JP"))

            Picker("時刻", selection: $hourPickerIndex) {
                ForEach(0 ..< Event.hours.count, id: \.self) { i in
                    Text(Event.hourString(Event.hours[i].0, Event.hours[i].1))
                }
                Text("カスタム").tag(-1)
            }
            .onChange(of: hourPickerIndex) { _ in
                withAnimation {
                    event.selectedHour = hourPickerIndex
                }
            }
            .pickerStyle(.inline)

            if (event.selectedHour == -1) {
                Section {
                    HStack {
                        Picker("開始時刻", selection: $event.startHour) {
                            ForEach(0 ..< 24, id: \.self) { i in
                                Text(String(i))
                            }
                        }
                        .onChange(of: event.startHour) { _ in
                            if (event.startHour >= event.endHour) {
                                withAnimation {
                                    event.endHour = event.startHour + 1
                                }
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                        
                        Text("－")
                        
                        Picker("終了時刻", selection: $event.endHour) {
                            ForEach(1 ... 24, id: \.self) { i in
                                Text(String(i))
                            }
                        }
                        .onChange(of: event.endHour) { _ in
                            if (event.startHour >= event.endHour) {
                                withAnimation {
                                    event.startHour = event.endHour - 1
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

            Picker("場所", selection: $event.location) {
                ForEach(modelData.locations) { location in
                    Text(location.short).tag(location.id)
                }
            }

            HStack {
                Text("コート番号")
                TextField("入力", text: $event.courtNumber)
                    .multilineTextAlignment(TextAlignment.trailing)
            }
        }
    }
}

struct EventEdit_Previews: PreviewProvider {
    static var previews: some View {
        EventEdit(event: .constant(Event(title: "", date: Date(), selectedHour: 0, location: 0, courtNumber: "")))
            .environmentObject(ModelData())
    }
}
