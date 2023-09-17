//
//  Single.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct Single: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EventTitle.calendar_id, ascending: true)],
        animation: .default)
    private var eventTitles: FetchedResults<EventTitle>
    
    @EnvironmentObject var modelData: ModelData
    @State private var showAddAlert = false
    @State private var showAddErrorAlert = false
    @State private var showAddSuccessAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack {
                Text("イベントを作成")
                    .bold()
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    Button("追加") {
                        showAddAlert = true
                    }
                    .disabled(modelData.calendar == nil)
                    .alert("カレンダーに追加", isPresented: $showAddAlert) {
                        Button("キャンセル") {
                        }
                        Button("OK") {
                            do {
                                try modelData.eventManager.addEvent(modelData: modelData)
                                showAddSuccessAlert = true
                                // EventTitle を保存
                                addEventTitle(calendarId: modelData.calendar!.calendarIdentifier, name: modelData.event.title)
                            } catch {
                                print(error)
                                showAddErrorAlert = true
                            }
                        }
                    } message: {
                        Text("以下のイベントをカレンダーに追加してもよろしいですか？\n\n\(modelData.event.eventString(modelData: modelData))")
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

            EventEdit()
        }
        .onAppear {
            modelData.getCalendar()
        }
    }

    private func addEventTitle(calendarId: String, name: String) {
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

struct Single_Previews: PreviewProvider {
    static var previews: some View {
        Single()
            .environmentObject(ModelData())
    }
}
