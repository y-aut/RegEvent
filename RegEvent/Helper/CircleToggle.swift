//
//  CircleToggle.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/17.
//

import Foundation
import SwiftUI

struct CircleToggle: ToggleStyle {
    var text: String
    let size = CGFloat(30)

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            if (configuration.isOn) {
                Text(text)
                    .frame(width: size, height: size)
                    .foregroundColor(Color.white)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            } else {
                Text(text)
                    .frame(width: size, height: size)
                    .foregroundColor(Color.accentColor)
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
            }
        }
        .buttonStyle(.plain)
    }
}
