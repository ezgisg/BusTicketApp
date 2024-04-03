//
//  Bundle + Extension.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import Foundation

extension Bundle {
    func decode<T:Decodable>(_ type: T.Type, from file: String) -> T {
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
        guard let contents = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle")
        }
        return contents
    }
}



extension String {
    var genderEnum: Gender {
        switch self.lowercased() {
        case "male":
            return .male
        case "female":
            return .female
        default:
            return .empty
        }
    }
}
