//
//  ViewController.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 28.03.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate {
    
    var tripNumber = Int()
    let voyagesArray = [["Istanbul","Ankara","01/07/2024 12:30:00"],["Sinop","Trabzon","03/08/2024 15:00:00"]]
    let voyagesSeatArray = [[[1,Gender.empty.toString()]
                             ,[2,Gender.male.toString()]
                             ,[3,Gender.empty.toString()]
                             ,[4,Gender.empty.toString()]
                             ,[5,Gender.empty.toString()]
                             ,[6,Gender.female.toString()]
                             ,[7,Gender.empty.toString()]
                             ,[8,Gender.empty.toString()]
                             ,[9,Gender.empty.toString()]
                             ,[10,Gender.empty.toString()]
                             ,[11,Gender.empty.toString()]
                             ,[12,Gender.empty.toString()]
                             ,[13,Gender.empty.toString()]
                             ,[14,Gender.empty.toString()]
                             ,[15,Gender.female.toString()]
                             ,[16,Gender.empty.toString()]
                             ,[17,Gender.empty.toString()]
                             ,[18,Gender.empty.toString()]
                             ,[19,Gender.empty.toString()]
                             ,[20,Gender.empty.toString()]
                             ,[21,Gender.empty.toString()]
                             ,[22,Gender.empty.toString()]
                             ,[23,Gender.empty.toString()]
                             ,[24,Gender.empty.toString()]
                             ,[25,Gender.empty.toString()]
                             ,[26,Gender.empty.toString()]
                             ,[27,Gender.empty.toString()]
                             ,[28,Gender.empty.toString()]
                             ,[29,Gender.empty.toString()]
                             ,[30,Gender.empty.toString()]
                             ,[31,Gender.female.toString()]
                             ,[32,Gender.empty.toString()]
                             ,[33,Gender.empty.toString()]
                             ,[34,Gender.empty.toString()]
                             ,[35,Gender.empty.toString()]
                             ,[36,Gender.empty.toString()]
                             ,[37,Gender.empty.toString()]
                             ,[38,Gender.empty.toString()]
                             ,[39,Gender.empty.toString()]
                             ,[40,Gender.male.toString()]
                             ,[41,Gender.empty.toString()]
                             ,[42,Gender.empty.toString()]
                             ,[43,Gender.empty.toString()]
                             ,[44,Gender.empty.toString()]
                             ,[45,Gender.empty.toString()]
],[[1,Gender.empty.toString()]
        ,[2,Gender.female.toString()]
        ,[3,Gender.female.toString()]
        ,[4,Gender.empty.toString()]
        ,[5,Gender.empty.toString()]
        ,[6,Gender.female.toString()]
        ,[7,Gender.empty.toString()]
        ,[8,Gender.empty.toString()]
        ,[9,Gender.empty.toString()]
        ,[10,Gender.empty.toString()]
        ,[11,Gender.empty.toString()]
        ,[12,Gender.empty.toString()]
        ,[13,Gender.empty.toString()]
        ,[14,Gender.empty.toString()]
        ,[15,Gender.female.toString()]
        ,[16,Gender.empty.toString()]
        ,[17,Gender.empty.toString()]
        ,[18,Gender.empty.toString()]
        ,[19,Gender.male.toString()]
        ,[20,Gender.empty.toString()]
        ,[21,Gender.empty.toString()]
        ,[22,Gender.empty.toString()]
        ,[23,Gender.empty.toString()]
        ,[24,Gender.empty.toString()]
        ,[25,Gender.empty.toString()]
        ,[26,Gender.empty.toString()]
        ,[27,Gender.empty.toString()]
        ,[28,Gender.male.toString()]
        ,[29,Gender.empty.toString()]
        ,[30,Gender.empty.toString()]
        ,[31,Gender.female.toString()]
        ,[32,Gender.empty.toString()]
        ,[33,Gender.empty.toString()]
        ,[34,Gender.empty.toString()]
        ,[35,Gender.empty.toString()]
        ,[36,Gender.empty.toString()]
        ,[37,Gender.empty.toString()]
        ,[38,Gender.empty.toString()]
        ,[39,Gender.male.toString()]
        ,[40,Gender.male.toString()]
        ,[41,Gender.empty.toString()]
        ,[42,Gender.empty.toString()]
        ,[43,Gender.empty.toString()]
        ,[44,Gender.empty.toString()]
        ,[45,Gender.empty.toString()]
]]
    
    let sections = Bundle.main.decode([Section].self, from: "dataSeats.json")
    var collectionView : UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Seats>?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let screenWidthSpace: CGFloat = 40
    let screenHeightSpace: CGFloat = 10
    let screenHeightRatio: CGFloat = 0.7
    

    var infoLabel = UILabel()
    var directionLabel = UILabel()
    var buyButton = UIButton()
    
//    var seatStatus = [
//        BusSeatsDetail(gender: .male, seatNumber: 1),
//        BusSeatsDetail(gender: .male, seatNumber: 2),
//        BusSeatsDetail(gender: .empty, seatNumber: 3),
//        BusSeatsDetail(gender: .female, seatNumber: 4),
//        BusSeatsDetail(gender: .female, seatNumber: 5),
//        BusSeatsDetail(gender: .female, seatNumber: 38)
//    ]
    var voyageClass : [Voyage]? = []
    let selectedRouteID = UUID(uuidString: "8E39ED36-937D-452D-8773-6AB7E1ACB9B2")

//    var dateArray = [Any]()

    
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
    
        
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
               if !isFirstLaunch {
                 
                   createCoreData()
              
                   UserDefaults.standard.set(true, forKey: "isFirstLaunch")
               }
        
        getCoreData()
        
        if let findingRouteIndex = voyageClass?.firstIndex(where: { $0.busID == selectedRouteID }) {
         tripNumber = findingRouteIndex
        }

  
//        fillSeatStatus()
        
        if let voyageClass, voyageClass.count > 0 {
            for i in 0...voyageClass.count - 1 {
                print("\(i). inci voyageclass elemanlari")
                print("initialPoint: \(voyageClass[i].initialPoint)")
                print("finalPoint: \(voyageClass[i].finishPoint)")
                print("UUID si: \(voyageClass[i].busID)")
                print("initialDateYear: \(voyageClass[i].voyageDate.year)")
                print("initialDateMonth: \(voyageClass[i].voyageDate.month)")
                print("initialDateDay: \(voyageClass[i].voyageDate.day)")
                print("initialDate Hour: \(voyageClass[i].voyageDate.hour.hour)")
                print("initialDate Minute: \(voyageClass[i].voyageDate.hour.minute)")
                for j in 0...(voyageClass[i].seatsStatus.count) - 1 {
                    print("seatNumber \(voyageClass[i].seatsStatus[j].seatNumber), seatGender: \(voyageClass[i].seatsStatus[j].gender)")
    
                }
            }
        }
        let collectionViewHeight = view.bounds.height * screenHeightRatio
        let collectionViewFrame = CGRect(
            x: Int(screenWidthSpace) / 2 ,
            y: Int(view.bounds.height * 0.85 - collectionViewHeight) ,
            width: Int(screenWidth) - Int(screenWidthSpace),
            height: Int(collectionViewHeight)
        )
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: createCompositionalLayout())
        collectionView.layer.cornerRadius = 5
        collectionView.backgroundColor = .systemGray6
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        view.addSubview(collectionView)
        //        changeSeats(seatStatus: seatStatus)
        //        changeSeats()
        //        collectionView.reloadData()
        
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
        directionLabel.text = "Direction: \(voyageClass?[tripNumber].initialPoint ?? "") to \(voyageClass?[tripNumber].finishPoint ?? "")"
    
        view.addSubview(directionLabel)
        
        let buyFrame = CGRect(x: (Int(screenWidth) - 160)/2 , y: Int(view.bounds.height * 0.89), width: 160, height: Int(view.bounds.height * 0.06))
        buyButton = UIButton(frame: buyFrame)
        buyButton.backgroundColor = .systemBlue
        buyButton.layer.cornerRadius = 5
        buyButton.setTitle( "Buy The Ticket", for: .normal)
        buyButton.isUserInteractionEnabled = true
        view.addSubview(buyButton)
        buyButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        collectionView.register(SingleCell.self, forCellWithReuseIdentifier: SingleCell.reuseIdentifier)
        createDataSource()
        reloadData()
        
    }
    
    //    MARK: DIDAPPEAR
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeSeats2()
    }
    
    // MARK : COMPOSITIONAL LAYOUT
    
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
    
//    MARK: CREATE DATASOURCE
    
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
    
//    MARK: RELOAD DATASOURCE
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Seats>()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.seats, toSection: section)
        }
        
        dataSource?.apply(snapshot)
    }
    
    
    //    MARK: CELL CONFIGURE
    private func configure<T: seatProtocol>(_ cellType: T.Type, with seat: Seats, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        cell.configure(with: seat)
        return cell
    }
    
    //    MARK: COLLECTIONVIEW SELECT ITEM
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
            let nextToSelectedSeat = self.voyageClass?[tripNumber].seatsStatus.first(where: { $0.seatNumber == nextSeatNumber })
            
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
    
}
 
// MARK: FILL THE SEAT IMAGES AND ENABLERS
private extension ViewController {
//    final func changeSeats() {
//        sections.enumerated().forEach { sectionIndex, section in
//            section.seats.enumerated().forEach { seatIndex, seats in
//                let cell = collectionView.cellForItem(at: [sectionIndex,seatIndex]) as? SingleCell
//                seatStatus.forEach { seat in
//                    guard seat.seatNumber == seats.seatNumber else { return }
//                    let (image, bool) = seat.determineSeatStatus()
//                    cell?.seatView.image = image
//                    cell?.isUserInteractionEnabled = bool
//                }
//            }
//        }
//    }
    
    final func changeSeats2() {
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
    
    
    
    //    MARK: DEFINING SEAT STATUS
//    final func fillSeatStatus() {
//        let existedNumbers = seatStatus.map { $0.seatNumber }
//        let numbers = Array(1...45)
//        numbers.forEach { seatNumber in
//            guard !existedNumbers.contains(seatNumber) else { return }
//            seatStatus.append(BusSeatsDetail(gender: .empty, seatNumber: seatNumber))
//        }
//    }
    
    @objc func buttonClicked() {
        
        

        
        print("butona basildi")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BusStatus")
        
        fetchRequest.predicate = NSPredicate(format: "busID == %@", selectedRouteID!.uuidString)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first as? NSManagedObject {
//                    result.setValue("Istanbul", forKey: "busInitialPoint")
                result.willAccessValue(forKey: "seatR")
                if let seatStatuses = result.value(forKey: "seatR") as? Set<NSManagedObject> {
                    result.didAccessValue(forKey: "seatR")
              
                    
                    // BURAYI PERFORMANS ANLAMINDA IYILESTIRMEK GEREK
                    
                    for seatStatus in seatStatuses {
                        guard let seatNum = seatStatus.value(forKey: "seatNumber") as? Int else { continue }
                        sections.enumerated().forEach { sectionIndex, section in
                            section.seats.enumerated().forEach { seatIndex, seats in
                                let cell = collectionView.cellForItem(at: [sectionIndex,seatIndex]) as? SingleCell
                                print("section index \(sectionIndex)  seat index \(seatIndex)")
                                print("coredatadaki seatnum \(seatNum)")
                                print("celldeki seatnum \(cell?.seatNumLabel.text)")
                                    guard cell?.seatNumLabel.text == String(seatNum) else { return }
                                    print("burada1")
                                    guard cell?.seatView.image != UIImage(named: "whiteseat") else { return }
                                    print("image \(cell?.seatView.image)")
                                    print("burada2")
                                guard cell?.seatView.image == UIImage(named: "pinkSelected") else { return seatStatus.setValue(Gender.male.toString(), forKey:  "seatGender") }
                                seatStatus.setValue(Gender.female.toString(), forKey:  "seatGender")
                            
                                   
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


//    MARK: COREDATA FUNCS

extension ViewController {
    
    


    func createCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        for num in 0...voyagesArray.count - 1 {
    
            let newBus = NSEntityDescription.insertNewObject(forEntityName: "BusStatus",  into: context)
            newBus.setValue(voyagesArray[num][0], forKey: "busInitialPoint")
            newBus.setValue(voyagesArray[num][1], forKey: "busFinalPoint")
            let busID = UUID()
            newBus.setValue(busID, forKey: "busID")
      
     
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            let dateString = voyagesArray[num][2]

            if let date = dateFormatter.date(from: dateString) {
                let nsDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
                newBus.setValue(nsDate, forKey: "date")
            
            }
            
            for seats in voyagesSeatArray[num] {
                let seat = NSEntityDescription.insertNewObject(forEntityName: "SeatStatus",  into: context)
                seat.setValue(seats[1], forKey: "seatGender")
                seat.setValue(seats[0], forKey: "seatNumber")
                seat.setValue(newBus, forKey:  "busR")
            }
            
//            for seatNumber in 1...45 {
//
//                let seat = NSEntityDescription.insertNewObject(forEntityName: "SeatStatus",  into: context)
//
//                if seatNumber % 2 == 0 {
//                    seat.setValue(Gender.female.toString(), forKey: "seatGender")
//                } else {
//                    seat.setValue(Gender.male.toString(), forKey: "seatGender")
//                }
//                seat.setValue(seatNumber, forKey: "seatNumber")
//                seat.setValue(newBus, forKey:  "busR")
//            }
        }
        
        
        do {
            try context.save()
        } catch  {
            print("veri kaydedilemedi")
        }
    }
    
    

    
    func getCoreData() {
        
//        busInitial.removeAll(keepingCapacity: false)
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
              
                        if let y = components.year,
                           let mo = components.month,
                           let d = components.day,
                           let h = components.hour,
                           let mi = components.minute {
                            year = y
                            month = mo
                            day = d
                            hour = h
                            minute = mi
                            
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
                        let vyg = Voyage(busID: UUID, initialPoint: initial, finishPoint: final, seatsStatus: seatsSeries, voyageDate: voyageD)
                        voyageClass?.append(vyg)
                        
                    }
              
                    
                }
                //self.collectionView.reloadData()
            } else {
                print("data yok")
            }
        }
            catch {
                print("data alınamadı")
            }
    }


}

