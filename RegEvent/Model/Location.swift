//
//  Court.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/16.
//

import Foundation

struct Location: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var short: String
    var display: String
    var match: String
}
