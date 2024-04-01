//
//  ViewController.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate {
    
    let sections = Bundle.main.decode([Section].self, from: "dataSeats.json")
    var collectionView : UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Seats>?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let screenWidthSpace: CGFloat = 40
    let screenHeightSpace: CGFloat = 10
    let screenHeightRatio: CGFloat = 0.7
    let busRow: CGFloat = 15
    let busColumn: CGFloat = 5
    let seatProportion: CGFloat = 2
    var infoLabel = UILabel()
    var buyButton = UIButton()
    var seatStatus = [selectedSeatsDetail(gender: .male, seatNumber: 1), selectedSeatsDetail(gender: .male, seatNumber: 2),  selectedSeatsDetail(gender: .empty, seatNumber: 3), selectedSeatsDetail(gender: .female, seatNumber: 4), selectedSeatsDetail(gender: .female, seatNumber: 5) ]
    
    enum SectionKind: Int, CaseIterable {
        case first
        case second
        case third
        
        var itemGroupCount: Int {
            switch self {
            case .first:
                return 14
            case .second:
                return 1
            case .third:
                return 7
            }
        }
        
        var seatCount: Int {
            switch self {
            case .first:
                return 14
            case .second:
                return 1
            case .third:
                return 13
            
            }
        }
   
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        for seatNumber in 6...45 {
            seatStatus.append(selectedSeatsDetail(gender: .empty, seatNumber: seatNumber))
        }
      
        
        let collectionViewHeight = view.bounds.height * screenHeightRatio
        let collectionViewFrame = CGRect(x: Int(screenWidthSpace) / 2 , y: Int(view.bounds.height * 0.85 - collectionViewHeight) , width: Int(screenWidth) - Int(screenWidthSpace), height: Int(collectionViewHeight))
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: createCompositionalLayout())
        collectionView.layer.cornerRadius = 5
        collectionView.backgroundColor = .systemGray6
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        view.addSubview(collectionView)
//        changeSeats()
//        collectionView.reloadData()

        let infoLabelFrame = CGRect(x: 0 , y: Int(view.bounds.height * 0.05), width: Int(screenWidth), height: Int(view.bounds.height * 0.10))
        infoLabel = UILabel(frame: infoLabelFrame)
        infoLabel.textAlignment = .center
        infoLabel.textColor = .black
        infoLabel.numberOfLines = 3
        infoLabel.text = "Selected Seats: "
        view.addSubview(infoLabel)
        
        let buyFrame = CGRect(x: (Int(screenWidth) - 160)/2 , y: Int(view.bounds.height * 0.89), width: 160, height: Int(view.bounds.height * 0.06))
        buyButton = UIButton(frame: buyFrame)
        buyButton.backgroundColor = .systemBlue
        buyButton.layer.cornerRadius = 5
        buyButton.setTitle( "Buy The Ticket", for: .normal)
        view.addSubview(buyButton)
        
        collectionView.register(SingleCell.self, forCellWithReuseIdentifier: SingleCell.reuseIdentifier)
        createDataSource()
        reloadData()
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeSeats(seatStatus: seatStatus)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout {
            [self] sectionIndex,
            NSCollectionLayoutEnvironment in
            
            var IndexSectionKind: SectionKind  {
                switch sectionIndex {
                case 0:
                    return .first
                case 1:
                    return .second
                default:
                    return .third
                }
            }
            
            let availableSeatWidth = (screenWidth - screenWidthSpace) / (busColumn * seatProportion)
            let availableSeatHeight = (screenHeight * screenHeightRatio - screenHeightSpace) / busRow
            let minSeatSideLength = CGFloat(Int(min(availableSeatWidth, availableSeatHeight)))
            
            let coveredWidth = minSeatSideLength * busColumn * seatProportion
            let coveredHeight = minSeatSideLength * busRow
            let availableWidthSpace = collectionView.frame.width - coveredWidth > 0 ?  collectionView.frame.width - coveredWidth : 0
            let availableHeightSpace = collectionView.frame.height - coveredHeight > 0 ? collectionView.frame.height - coveredHeight : 0
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(minSeatSideLength * seatProportion), heightDimension: .absolute(minSeatSideLength * CGFloat(IndexSectionKind.itemGroupCount)))
            let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: layoutItem, count: IndexSectionKind.itemGroupCount)
            var layoutSection : NSCollectionLayoutSection
            
            switch IndexSectionKind {
            case .third:
                layoutGroup.edgeSpacing = .init(leading: .fixed(0), top: nil, trailing: nil, bottom: .fixed((busRow - CGFloat(IndexSectionKind.seatCount)) * minSeatSideLength))
                let groupSize2 = NSCollectionLayoutSize(
                    widthDimension: .absolute(minSeatSideLength * seatProportion),
                    heightDimension: .absolute(minSeatSideLength * CGFloat((IndexSectionKind.itemGroupCount - 1)))
                )
                let layoutGroup2 = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize2,
                    repeatingSubitem: layoutItem,
                    count: IndexSectionKind.itemGroupCount - 1
                )
                let nestedSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(minSeatSideLength * seatProportion),
                    heightDimension: .absolute(minSeatSideLength * busRow)
                )
                let nestedGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: nestedSize,
                    subitems: [layoutGroup,layoutGroup2]
                )
                layoutSection = NSCollectionLayoutSection(group: nestedGroup)
                
            case .second:
                layoutGroup.edgeSpacing = .init(
                    leading: nil,
                    top: .fixed(minSeatSideLength * (busRow - CGFloat(IndexSectionKind.seatCount))),
                    trailing: .fixed(minSeatSideLength * seatProportion),
                    bottom: nil
                )
                layoutSection = NSCollectionLayoutSection(group: layoutGroup)
                
            default:
                layoutGroup.edgeSpacing = .init(
                    leading: .fixed(availableWidthSpace / 2) ,
                    top: .fixed(minSeatSideLength * (busRow - CGFloat(IndexSectionKind.itemGroupCount))),
                    trailing: nil,
                    bottom: nil
                )
                layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            }
            
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: availableHeightSpace / 2 , leading: 0, bottom: 0, trailing: 0)
            layoutSection.orthogonalScrollingBehavior = .none
            return layoutSection
        }
        
        layout.configuration = config
        return layout
    }
    
    func createDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, Seats>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch self.sections[indexPath.section].type {
            case "single":
                return self.configure(SingleCell.self, with: itemIdentifier, for: indexPath)
            default:
                return self.configure(SingleCell.self, with: itemIdentifier, for: indexPath)
            }
        })

    }
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Seats>()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.seats, toSection: section)
        }
        
        dataSource?.apply(snapshot)
    }
    
    private func configure<T: seatProtocol>(_ cellType: T.Type, with seat: Seats, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        cell.configure(with: seat)
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? SingleCell
        if let image = cell?.seatView.image , image == UIImage(named: "blueSelected") || image == UIImage(named: "pinkSelected")  {
             cell?.seatView.image = UIImage(named: "whiteseat")
        } else {
            let genderAlert = UIAlertController(title: "Gender Warning", message: "You cant select opposite gender", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .cancel)
            genderAlert.addAction(okButton)
        
            let section = sections[indexPath.section]
            let nextSeatNumber = section.seats[indexPath.item].nextSeatNumber
            let nextToSelectedSeat = self.seatStatus.first(where: { $0.seatNumber == nextSeatNumber })
          
        
       
            let alert = UIAlertController(title: "Select Gender", message: "Please select passenger gender:", preferredStyle: .alert)
            let buttonM = UIAlertAction(title: Gender.male.toString() , style: .default, handler: { _ in
                if (nextToSelectedSeat?.gender.toString() ?? "Empty") == Gender.female.toString() {
                    self.present(genderAlert, animated: true, completion: nil)
                } else {
                    cell?.seatView.image = UIImage(named: "blueSelected")
                }

            })
            let buttonF = UIAlertAction(title: Gender.female.toString() , style: .default, handler: { _ in
                if (nextToSelectedSeat?.gender.toString() ?? "Empty") == Gender.male.toString() {
                    self.present(genderAlert, animated: true, completion: nil)
                } else {
                    cell?.seatView.image = UIImage(named: "pinkSelected")
                }
            })
            alert.addAction(buttonF)
            alert.addAction(buttonM)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func changeSeats(seatStatus: [selectedSeatsDetail]) {
        for (sectionIndex, section) in sections.enumerated() {
            for (seatIndex, seats) in section.seats.enumerated() {
                let cell = collectionView.cellForItem(at: [sectionIndex,seatIndex]) as? SingleCell
                for seat in seatStatus {
                    if seat.seatNumber == seats.seatNumber {
                        let (image, bool) = seat.determineSeatStatus()
                            cell?.seatView.image = image
                            cell?.isUserInteractionEnabled = bool
                    }
                }
            }
        }
    }
   
    
    
}
