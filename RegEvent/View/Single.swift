//
//  Single.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct Single: View {
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
}

struct Single_Previews: PreviewProvider {
    static var previews: some View {
        Single()
            .environmentObject(ModelData())
    }
}
