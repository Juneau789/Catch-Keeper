//
//  Item.swift
//  FishingLogApp
//
//  Created by Harrison Juneau on 8/15/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var species: String
    var weight: Double
    
    init(timestamp: Date, species: String, weight: Double) {
        self.timestamp = timestamp
        self.species = species
        self.weight = weight
    }
}
