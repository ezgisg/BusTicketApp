//
//  Int + Extension.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 9.04.2024.
//

import Foundation

extension Int {
    /// Convert the integer value to %02d formatted string. (2 digits)
    /// - Returns: String which was integer
    func twoDigit() -> String {
        String(format: "%02d", self)
    }
}
