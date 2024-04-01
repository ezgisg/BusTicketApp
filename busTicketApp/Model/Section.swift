//
//  Section.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import Foundation

struct Section: Decodable, Hashable {
    let section: Int
    let type: String
    let seats: [Seats]
}
