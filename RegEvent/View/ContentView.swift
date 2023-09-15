//
//  ContentView.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Single()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
