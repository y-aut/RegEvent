//
//  ModelData.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import Foundation

final class ModelData: ObservableObject {
    @Published var event = Event(date: Date(), selectedHour: 0)
}
