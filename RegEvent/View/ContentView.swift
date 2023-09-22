//
//  ContentView.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var selection: Tab = .single

    enum Tab {
        case single
        case multiple
    }

    var body: some View {
        TabView(selection: $selection) {
            Single(calendar: modelData.defaultCalendar)
                .tabItem {
                    Label("登録", systemImage: "calendar.badge.plus")
                }
                .tag(Tab.single)

            Multiple(calendar: modelData.defaultCalendar)
                .tabItem {
                    Label("一括", systemImage: "list.bullet")
                }
                .tag(Tab.multiple)
        }
        .onAppear {
            modelData.getCalendar()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
