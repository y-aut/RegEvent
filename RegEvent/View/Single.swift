//
//  Single.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

struct Single: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        EventEdit(event: $modelData.event)
    }
}

struct Single_Previews: PreviewProvider {
    static var previews: some View {
        Single()
            .environmentObject(ModelData())
    }
}
