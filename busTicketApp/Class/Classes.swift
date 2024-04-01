//
//  Classes.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import Foundation
import UIKit

class Passengers {
    var passenger: [Passenger]
    var date: Date
    var hour: Hour
    var seatArray: [Int]
    var seatNum: Int
    var fromtoDirection: Direction
    
    init(passenger: [Passenger], date: Date, hour: Hour, seatArray: [Int], seatNum: Int, fromtoDirection: Direction) {
        self.passenger = passenger
        self.date = date
        self.hour = hour
        self.seatArray = seatArray
        self.seatNum = seatNum
        self.fromtoDirection = fromtoDirection
    }
    
    
    func isSeatAvailable(selectedSeats: selectedSeats, newPassengers: Passengers) -> Bool {
        
        
        for seatNum in seatArray {
            if selectedSeats.selectedSeats.contains(where: { $0.seatNumber == seatNum }) {
                return false
            }
        }
        return true
    }
    
    func reservation() -> Bool {
        if (seatArray.count > 5) {
            return false
        } else {
            return true
        }
    }
    
    func addSeat() {
        seatArray.append(seatNum)
        
    }
    
    func printTicket() {
        for i in 1 ... seatNum {
            print("passenger info: \(passenger[i].id)-\(passenger[i].surname)-\(passenger[i].name) - direction: from \(fromtoDirection.initialPoint) to \(fromtoDirection.finishPoint) - seat num: \(seatArray[i]) - date: \(hour.minute) : \(hour.hour) \(date.day)/\(date.month)/\(date.year)")
        }
    }
    
}

class Passenger {
    var name: String = "Noname"
    var surname: String = "Noname"
    var gender: Gender
    var id: Int = 0
    
    init(name: String, surname: String, gender: Gender, id: Int) {
        self.name = name
        self.surname = surname
        self.gender = gender
        self.id = id
    }
}

class Date {
    var day: Int = 01
    var month: Int = 01
    var year: Int = 2024
    
    init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
}

class Hour {
    var hour: Int = 00
    var minute: Int = 00
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

class Direction {
    var initialPoint: String
    var finishPoint: String
    
    init(initialPoint: String, finishPoint: String) {
        self.initialPoint = initialPoint
        self.finishPoint = finishPoint
        
    }
}

class selectedSeats {
    var selectedSeats : [SelectedSeatsDetail]
    
    init(selectedSeats: [SelectedSeatsDetail]) {
        self.selectedSeats = selectedSeats
    }
    
}

class SelectedSeatsDetail {
    var gender: Gender
    var seatNumber: Int
    
    init(gender: Gender, seatNumber: Int) {
        self.gender = gender
        self.seatNumber = seatNumber
    }
    
    func determineSeatStatus() -> (UIImage, Bool) {
        switch gender {
        case .male:
            return (UIImage(named: "blue") ?? UIImage(), false)
        case .female:
            return (UIImage(named: "pink") ?? UIImage(), false)
        default:
            return (UIImage(named: "whiteseat") ?? UIImage(), true)
        }
    }
    
}

class Voyage {
    var direction : [Direction]
    var seatsStatus: [SelectedSeatsDetail]
    var voyageDate: [Date]
    var voyageHour: [Hour]
    
    init(direction: [Direction], seatsStatus: [SelectedSeatsDetail], voyageDate: [Date], voyageHour: [Hour]) {
        self.direction = direction
        self.seatsStatus = seatsStatus
        self.voyageDate = voyageDate
        self.voyageHour = voyageHour
    }
    
}

enum Gender {
    case male
    case female
    case empty
    
    func toString() -> String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        default:
            return "Empty"
        }
    }
}

