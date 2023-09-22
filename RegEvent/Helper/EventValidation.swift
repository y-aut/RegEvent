//
//  EventValidation.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/22.
//

import SwiftUI

struct EventValidation: View {
    @EnvironmentObject var modelData: ModelData
    var result: EventValidationResult
    var maxWidth: CGFloat

    @State private var opened: Bool = false

    var body: some View {
        HStack {
            Image(systemName: iconName())
                .padding(3)

            if (opened) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(result.toString(modelData: modelData))
                }
                .padding(.leading, -6)
                .padding(.trailing, 9)
                .frame(maxWidth: maxWidth)
                .fixedSize()
            }
        }
        .background(backgroundColor())
        .foregroundColor(foregroundColor())
        .cornerRadius(14)
        .onTapGesture {
            withAnimation {
                opened.toggle()
            }
        }
    }

    func iconName() -> String {
        switch (result.result) {
        case .Success: return "checkmark.circle.fill"
        case .Warning: return "exclamationmark.circle.fill"
        case .Error: return "xmark.circle.fill"
        case .Unparsed: fatalError("Result must not be Unparsed.")
        }
    }

    func backgroundColor() -> Color {
        switch (result.result) {
        case .Success: return Color(red: 0.86, green: 1, blue: 0.77)
        case .Warning: return Color(red: 1, green: 0.95, blue: 0.8)
        case .Error: return Color(red: 1, green: 0.8, blue: 0.8)
        case .Unparsed: fatalError("Result must not be Unparsed.")
        }
    }

    func foregroundColor() -> Color {
        switch (result.result) {
        case .Success: return .green
        case .Warning: return Color(red: 1, green: 0.6, blue: 0)
        case .Error: return .red
        case .Unparsed: fatalError("Result must not be Unparsed.")
        }
    }
}

struct EventValidation_Previews: PreviewProvider {
    static var previews: some View {
        EventValidation(result: EventValidationResult.success(Event(title: "", date: Date(), selectedHour: 0, location: 1, courtNumber: "1")), maxWidth: 200)
            .environmentObject(ModelData())
    }
}
