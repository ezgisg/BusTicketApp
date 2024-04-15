//
//  ViewController.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    var wholeNumberString = ""
    let sections = Bundle.main.decode([Section].self, from: "dataSeats.json")
    var dataSource: UICollectionViewDiffableDataSource<Section, Seats>?
    var collectionView : UICollectionView!
    var infoLabel = UILabel()
    var directionLabel = UILabel()
    var buyButton = UIButton()
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let screenWidthSpace: CGFloat = 40
    let screenHeightSpace: CGFloat = 10
    let screenHeightRatio: CGFloat = 0.7

    var voyageClass : [Voyage]? = []
    var selectedRouteID : UUID?
    var tripNumber = Int()
    var tempSeats = selectedSeats(selectedSeats: [])
    
    let busRow: CGFloat = 15
    let busColumn: CGFloat = 5
    let seatProportion: CGFloat = 2
    
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
    
    //    MARK: DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()

        getCoreData()
        // temp variable , for selecting route
        if let findingRouteIndex = voyageClass?.firstIndex(where: { $0.busID == selectedRouteID }) {
            tripNumber = findingRouteIndex
        }
        configureView()
        // collectionview register and data funcs
        collectionView.register(SingleCell.self, forCellWithReuseIdentifier: SingleCell.reuseIdentifier)
        createDataSource()
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeSeatImage()
    }

}

//    MARK: Layout + Bundle

extension ViewController {
    
    func createDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, Seats>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return self.configure(SingleCell.self, with: itemIdentifier, for: indexPath)
        })
    }

    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Seats>()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.seats, toSection: section)
        }
        
        dataSource?.apply(snapshot)
        changeSeatImage()
        collectionView.reloadData()
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
    
    private func configure<T: seatProtocol>(_ cellType: T.Type, with seat: Seats, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        cell.configure(with: seat)
        return cell
    }
    
}

//    MARK: COREDATA FUNCS
extension ViewController {
    // mapping data from coredata to class
    func getCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BusStatus")
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    guard let initial = result.value(forKey: "busInitialPoint") as? String else {return}
                    guard let final = result.value(forKey: "busFinalPoint") as? String else {return}
                    guard let UUID = result.value(forKey: "busID") as? UUID else {return}
                    guard let date = result.value(forKey: "date") as? Date else {return}
                    var year = Int()
                    var month = Int()
                    var day = Int()
                    var hour = Int()
                    var minute = Int()
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    if let yearC = components.year,
                       let monthC = components.month,
                       let dayC = components.day,
                       let hourC = components.hour,
                       let minuteC = components.minute {
                        year = yearC
                        month = monthC
                        day = dayC
                        hour = hourC
                        minute = minuteC
                    }
                    let voyageH = VoyageHour(hour: hour, minute: minute)
                    let voyageD = VoyageDate(day: day, month: month, year: year, hour: voyageH)
                    
                    var seatsSeries : [BusSeatsDetail]? = []
                    result.willAccessValue(forKey: "seatR")
                    if let seatStatuses = result.value(forKey: "seatR") as? Set<NSManagedObject> {
                        result.didAccessValue(forKey: "seatR")
                        for seatStatus in seatStatuses {
                            guard let seatGender = seatStatus.value(forKey: "seatGender") as? String else { continue }
                            guard let seatNum = seatStatus.value(forKey: "seatNumber") as? Int else { continue }
                            let seatInfos = BusSeatsDetail(gender: seatGender.genderEnum, seatNumber: seatNum)
                            seatsSeries?.append(seatInfos)
                        }
                    }
                    if let seatsSeries {
                        let voyage = Voyage(busID: UUID, initialPoint: initial, finishPoint: final, seatsStatus: seatsSeries, voyageDate: voyageD)
                        voyageClass?.append(voyage)
                    }
                }
            } else {
                print("data yok")
            }
        }
        catch {
            print("data alınamadı")
        }
    }
}

//MARK: PROTOCOL-DELEGATE

extension ViewController: MessageDelegate {
    func sendMessage(ID: UUID) {
        selectedRouteID = ID
 
    }
}

//MARK: View Configuration
private extension ViewController {
    final func configureView() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.imageView?.contentMode = .scaleAspectFill // Fill the entire button with the image
        backButton.frame = CGRect(x: view.frame.width - 30 , y: 50 , width: 30, height: 30)
        view.addSubview(backButton)
        
        //  view settings
        let collectionViewHeight = view.bounds.height * screenHeightRatio
        let collectionViewFrame = CGRect(
            x: Int(screenWidthSpace) / 2 ,
            y: Int(view.bounds.height * 0.85 - collectionViewHeight) ,
            width: Int(screenWidth) - Int(screenWidthSpace),
            height: Int(collectionViewHeight)
        )
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: createCompositionalLayout())
        collectionView.layer.cornerRadius = 8
        collectionView.backgroundColor = .systemGray6
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.layer.borderWidth = 1
        view.addSubview(collectionView)
     
        let infoLabelFrame = CGRect(x: 5 , y: Int(view.bounds.height * 0.10), width: Int(screenWidth), height: Int(view.bounds.height * 0.05))
        infoLabel = UILabel(frame: infoLabelFrame)
        infoLabel.textAlignment = .left
        infoLabel.textColor = .black
        infoLabel.numberOfLines = 3
        infoLabel.text = "Selected Seats: "
        view.addSubview(infoLabel)
        
        let directionLabelFrame = CGRect(x: 5 , y: Int(view.bounds.height * 0.05), width: Int(screenWidth), height: Int(view.bounds.height * 0.05))
        directionLabel = UILabel(frame: directionLabelFrame)
        directionLabel.textAlignment = .left
        directionLabel.textColor = .black
        directionLabel.numberOfLines = 3
        directionLabel.text = "Direction: \(voyageClass?[tripNumber].initialPoint ?? "") to \(voyageClass?[tripNumber].finishPoint ?? "") \(voyageClass?[tripNumber].voyageDate.hour.hour.twoDigit() ?? ""):\(voyageClass?[tripNumber].voyageDate.hour.minute.twoDigit() ?? "") \(voyageClass?[tripNumber].voyageDate.day.twoDigit() ?? "")/\(voyageClass?[tripNumber].voyageDate.month.twoDigit() ?? "")/\(voyageClass?[tripNumber].voyageDate.year.twoDigit() ?? "")"
        view.addSubview(directionLabel)
        
        let buyFrame = CGRect(x: (Int(screenWidth) - 160)/2 , y: Int(view.bounds.height * 0.89), width: 160, height: Int(view.bounds.height * 0.06))
        buyButton = UIButton(frame: buyFrame)
        buyButton.backgroundColor = .systemBlue
        buyButton.layer.cornerRadius = 5
        buyButton.setTitle( "Buy The Ticket", for: .normal)
        buyButton.isUserInteractionEnabled = true
        view.addSubview(buyButton)
        buyButton.addTarget(self, action: #selector(buyButtonClicked), for: .touchUpInside)
        
    }
    
    /// Transforms cell's size to 0.8 scale witn 0.2 second.
    /// - Parameter cell: SingleCell value for the seat cell.
    final func makeClickAnimation(to cell: SingleCell?) {
        guard let cell else { return }
        let duration = 0.2
        let scale = 0.8
        UIView.animate(withDuration: duration, animations: {
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration) {
                cell.transform = .identity
            }
        }
    }
    
    // changing seats image and userinteraction
    final func changeSeatImage() {
        sections.enumerated().forEach { sectionIndex, section in
            section.seats.enumerated().forEach { seatIndex, seats in
                let cell = collectionView.cellForItem(at: [sectionIndex,seatIndex]) as? SingleCell
                
                voyageClass?[tripNumber].seatsStatus.forEach { seat in
                    guard seat.seatNumber == seats.seatNumber else { return }
                    let (image, bool) = seat.determineSeatStatus()
                    cell?.seatView.image = image
                    cell?.isUserInteractionEnabled = bool
                }
            }
        }
    }
    @objc func buyButtonClicked() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BusStatus")
        fetchRequest.predicate = NSPredicate(format: "busID == %@", selectedRouteID!.uuidString)
        do {
            
            self.infoLabel.text = "Selected Seats:"
            let results = try context.fetch(fetchRequest)
            if let result = results.first as? NSManagedObject {
                tempSeats.selectedSeats.removeAll(keepingCapacity: false)
                result.willAccessValue(forKey: "seatR")
                if let seatStatuses = result.value(forKey: "seatR") as? Set<NSManagedObject> {
                    result.didAccessValue(forKey: "seatR")
                    
                    // TO DO: will be reviewed to improve performance
                    for seatStatus in seatStatuses {
                        guard let seatNum = seatStatus.value(forKey: "seatNumber") as? Int else { continue }
                        sections.enumerated().forEach { sectionIndex, section in
                            section.seats.enumerated().forEach { seatIndex, seats in
                                let cell = collectionView.cellForItem(at: [sectionIndex,seatIndex]) as? SingleCell
                                guard cell?.seatNumLabel.text == String(seatNum) else { return }
                                guard cell?.seatView.image != UIImage(named: "pink") else { return }
                                guard cell?.seatView.image != UIImage(named: "blue") else { return }
                                guard cell?.seatView.image != UIImage(named: "whiteseat") else { return }
                                guard cell?.seatView.image == UIImage(named: "pinkSelected") else {
                                    cell?.seatView.image = UIImage(named: "blue")
                                    return seatStatus.setValue(Gender.male.toString(), forKey:  "seatGender") }
                                seatStatus.setValue(Gender.female.toString(), forKey:  "seatGender")
                                cell?.seatView.image = UIImage(named: "pink")
                            }
                        }
                    }
                }
            }

            do {
                try context.save()
            } catch {
                print("Değişiklikleri kaydederken hata oluştu: \(error.localizedDescription)")
            }
        } catch {
            print("Hata: \(error.localizedDescription)")
        }
    }
}

//MARK: Helpers
extension ViewController {
    func makeAlert(title: String, message: String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(button)
        present(alert, animated: true)
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: CollectionView
extension ViewController: UICollectionViewDelegate {
    // selecting seats on collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? SingleCell
        makeClickAnimation(to: cell)
        
        if let image = cell?.seatView.image , image == UIImage(named: "blueSelected") || image == UIImage(named: "pinkSelected")  {
            cell?.seatView.image = UIImage(named: "whiteseat")

            tempSeats.selectedSeats.removeAll { $0.seatNumber == Int(cell?.seatNumLabel.text ?? "") ?? 0 }
            guard tempSeats.selectedSeats.count > 0 else {
                wholeNumberString = ""
                return self.infoLabel.text = "Selected Seats: \(wholeNumberString) "}
            wholeNumberString = ""
            for i in 0...tempSeats.selectedSeats.count-1 {
             print("\(tempSeats.selectedSeats[i].seatNumber)")
                wholeNumberString += "\(tempSeats.selectedSeats[i].seatNumber), "
                self.infoLabel.text = "Selected Seats: \(wholeNumberString) "
            }
        } else {
            let section = sections[indexPath.section]
            let nextSeatNumber = section.seats[indexPath.item].nextSeatNumber
            let nextToSelectedSeat = self.voyageClass?[tripNumber].seatsStatus.first(where: { $0.seatNumber == nextSeatNumber })
           
            
            let alert = UIAlertController(title: "Select Gender", message: "Please select passenger gender:", preferredStyle: .alert)
            let buttonM = UIAlertAction(title: Gender.male.toString() , style: .default, handler: { [self] _ in
                if (nextToSelectedSeat?.gender.toString() ?? "Empty") == Gender.female.toString() {
                    self.makeAlert(title: "Gender Warning", message: "You cant select opposite gender")
                } else if (self.tempSeats.isSeatCountGreaterThanFive()) {
                    self.makeAlert(title: "Seat Count Warning", message: "You can not choose seat more than 5")
             
                } else {
                    cell?.seatView.image = UIImage(named: "blueSelected")
                    
                    let newSeat = BusSeatsDetail(gender: .male, seatNumber: Int(cell?.seatNumLabel.text ?? "") ?? 0)
                    self.tempSeats.selectedSeats.append(newSeat)
        
                    wholeNumberString = ""
                    for i in 0...self.tempSeats.selectedSeats.count-1 {
                        print("\(self.tempSeats.selectedSeats[i].seatNumber)")
                        wholeNumberString += "\(tempSeats.selectedSeats[i].seatNumber), "
                        self.infoLabel.text = "Selected Seats: \(wholeNumberString) "
                    }
                    
                }
                
            })
            let buttonF = UIAlertAction(title: Gender.female.toString() , style: .default, handler: { [self] _ in
            
                if (nextToSelectedSeat?.gender.toString() ?? "Empty") == Gender.male.toString() {
                    makeAlert(title: "Gender Warning", message: "You cant select opposite gender")
                   
                } else if (self.tempSeats.isSeatCountGreaterThanFive()) {
                    self.makeAlert(title: "Seat Count Warning", message: "You can not choose seat more than 5")
            
                } else {
                    cell?.seatView.image = UIImage(named: "pinkSelected")
                    
                    let newSeat = BusSeatsDetail(gender: .male, seatNumber: Int(cell?.seatNumLabel.text ?? "") ?? 0)
                    self.tempSeats.selectedSeats.append(newSeat)
                    

                    wholeNumberString = ""
                    for i in 0...tempSeats.selectedSeats.count-1 {
                     print("\(tempSeats.selectedSeats[i].seatNumber)")
                        wholeNumberString += "\(tempSeats.selectedSeats[i].seatNumber), "
                        self.infoLabel.text = "Selected Seats: \(wholeNumberString) "
                    }
             
                }
            })
            alert.addAction(buttonF)
            alert.addAction(buttonM)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
