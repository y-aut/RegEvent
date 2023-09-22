//
//  EventText.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/21.
//

import SwiftUI

struct EventText: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var modelData: ModelData

    @Binding var text: String
    @Binding var lines: [(String, EventValidationResult)]
    @Binding var events: [Event]
    @State private var draftText: String = ""

    var body: some View {
        VStack {
            HStack {
                Button("キャンセル") {
                    draftText = text
                    dismiss()
                }
                Spacer()
                Button("完了") {
                    text = draftText
                    lines = text.split(separator: "\n").map({ s in
                        (String(s), Event.parse(String(s), modelData: modelData))
                    })
                    events = lines.filter({ i in i.1.event != nil }).map({ i in i.1.event! })
                    dismiss()
                }
                .disabled(draftText.isEmpty)
            }
            .padding([.top, .horizontal])

            ZStack {
                TextEditor(text: $draftText)

                if (draftText.isEmpty) {
                    Text("ここにイベントを入力")
                        .foregroundColor(Color(UIColor.placeholderText.cgColor))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.leading, 5)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            draftText = text
        }
    }
}

struct EventText_Previews: PreviewProvider {
    static var previews: some View {
        EventText(text: .constant(""), lines: .constant([]), events: .constant([]))
            .environmentObject(ModelData())
    }
}
