//
//  Single.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct Single: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button("追加") {
                    showAlert = true
                }
                .alert("カレンダーに追加", isPresented: $showAlert) {
                    Button("キャンセル") {
                    }
                    Button("OK") {
                    }
                } message: {
                    Text("以下のイベントをカレンダーに追加してもよろしいですか？\n\n\(modelData.event.eventString(modelData: modelData))")
                }
            }

            EventEdit(event: $modelData.event)
        }
        .padding()
    }
}

struct Single_Previews: PreviewProvider {
    static var previews: some View {
        Single()
            .environmentObject(ModelData())
    }
}
