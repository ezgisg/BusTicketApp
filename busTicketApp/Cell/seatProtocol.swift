//
//  seatProtocol.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import Foundation

protocol seatProtocol {
    static var reuseIdentifier: String {get}
    func configure(with seatProtocol: Seats?)
}
