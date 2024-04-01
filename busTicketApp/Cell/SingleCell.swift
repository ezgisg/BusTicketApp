//
//  SingleCell.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import UIKit

class SingleCell: UICollectionViewCell, seatProtocol {
    static var reuseIdentifier = "single"
    
    let seatNumLabel = UILabel()
    let seatView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        seatNumLabel.translatesAutoresizingMaskIntoConstraints = false
        seatView.translatesAutoresizingMaskIntoConstraints = false
        
        seatView.addSubview(seatNumLabel)
        seatNumLabel.textAlignment = .center
        seatNumLabel.textColor = .black
        seatNumLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(seatView)
   
        
        NSLayoutConstraint.activate([
            seatNumLabel.topAnchor.constraint(equalTo: seatView.topAnchor, constant: 0),
            seatNumLabel.centerXAnchor.constraint(equalTo: seatView.centerXAnchor),
            seatView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            seatView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            seatView.topAnchor.constraint(equalTo: contentView.topAnchor),
            seatView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with seats: Seats?) {

        let seatNumberText = String(seats?.seatNumber ?? 0)
        seatNumLabel.text = seatNumberText
     
        
    }
}
