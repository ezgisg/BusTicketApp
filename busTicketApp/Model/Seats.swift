//
//  Seats.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import Foundation

struct Seats: Decodable, Hashable {
    let seatNumber: Int
    let nextSeatNumber: Int
}

