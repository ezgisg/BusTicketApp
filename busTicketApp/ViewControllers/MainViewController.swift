//
//  MainViewController.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 4.04.2024.
//

import UIKit
import CoreData

protocol MessageDelegate {
    func sendMessage(ID: UUID)
}


class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    
    @IBOutlet weak var busImageView: UIImageView!
    let onboardingMessages = ["Welcome!", "Let's Start"]
    let onboardingImages = ["bus", "busstop"]
    var controllers = [UIViewController]()
    let pageControl = UIPageControl()
    
    var delegate : MessageDelegate?
    
    var voyageClass : [Voyage]? = []
    let voyagesArray = [
        ["Istanbul","Ankara","01/07/2024 12:30:00"],
        ["Sinop","Trabzon","03/08/2024 15:00:00"],
        ["Sinop","Istanbul","03/08/2024 15:00:00"],
        ["Sinop","Trabzon","03/08/2024 18:00:00"]
    ]
    var voyagesSeatArray = [[[5,Gender.male.toString()],[4,Gender.female.toString()]],
                             [[10,Gender.male.toString()],[15,Gender.female.toString()]],
                            [[11,Gender.male.toString()],[12,Gender.female.toString()],[14,Gender.female.toString()],[18,Gender.male.toString()]],
                            [[6,Gender.male.toString()],[41,Gender.female.toString()]]]
    
    
    var selectedInitialPoint: String?
    var initialPointSet: Set<String> = []
    var initialPointArray: [String] = []
    var afterSelectionInitialPointsArray: [String] = []
    
    var finalPointSet: Set<String> = []
    var finalPointArray: [String] = []
    var selectedFinalPoint: String?
    var afterSelectionFinalPointsArray: [String] = []

    var selectedDatePoint: String?
    var datePointSet: Set<String> = []
    var datePointArray: [String] = []

    var busID : UUID?
    
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var chooseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        
        let vc1 = UIViewController()
        vc1.view.backgroundColor = .white
        controllers.append(vc1)
        
        let vc2 = UIViewController()
        vc2.view.backgroundColor = .white
        controllers.append(vc2)
        
        for i in 0...controllers.count - 1 {
            let messageLabel = UILabel(frame: CGRect(x: 10 , y: view.frame.width + 70 , width: view.frame.width - 20 , height: 100))
            messageLabel.text = onboardingMessages[i]
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = .boldSystemFont(ofSize: 50)
            controllers[i].view.addSubview(messageLabel)
            
            let view = UIImageView(frame: CGRect(x: 10, y: 50 , width: view.frame.width - 20 , height:  view.frame.width - 20 ))
            view.image = UIImage(named: onboardingImages[i])
            controllers[i].view.addSubview(view)
        }
        
        fillSeatGender()
        
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isFirstLaunch {
            createCoreData()
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        }
        
        getCoreData()
        createInitialPoint()
        createFinalPoint()
        createDatePoint()
        
        //  temp print
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
        
    
   
     
        fromPicker.delegate = self
        fromPicker.dataSource = self
        toPicker.delegate = self
        toPicker.dataSource = self
        datePicker.delegate = self
        datePicker.dataSource = self
        toPicker.isUserInteractionEnabled = false
        datePicker.isUserInteractionEnabled = false
        
        chooseButton.addTarget(self, action: #selector(chooseButtonTapped), for: .touchUpInside)
      
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseButtonTapped))
        busImageView.isUserInteractionEnabled = true
        busImageView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunchOnboarding")
        if !isFirstLaunch {
            self.onboardingVC()
            UserDefaults.standard.set(true, forKey: "isFirstLaunchOnboarding")
        }
      
    }

    
    func onboardingVC() {
        guard let first = controllers.first else {return}
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.dataSource = self
        
        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pageControl)
        NSLayoutConstraint.activate([
               pageControl.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
               pageControl.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -50)
           ])
        
        vc.setViewControllers([first], direction: .forward, animated: true)
        present(vc, animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController), index > 0 else {return nil}
        let previous = index - 1
        return controllers[previous]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController), index < controllers.count - 1 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.dismiss(animated: true, completion: nil)
            }
            return nil}
        let next = index + 1
        return controllers[next]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = controllers.firstIndex(of: currentViewController) else { return }
        pageControl.currentPage = currentIndex
    }
    
    
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
        guard let busID else {
            let alert = UIAlertController(title: "Missing Info", message: "Please select from, to and date points", preferredStyle: .alert)
            let button = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(button)
            present(alert, animated: true)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "firstNavigationController") as! UINavigationController
        let viewController = storyboard.instantiateViewController(withIdentifier: "busSeatBoard") as! ViewController
        delegate = viewController
        delegate?.sendMessage(ID: busID)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
    /*
     @IBAction func chooseButtonTapped(_ sender: UIButton) {
         guard let busID else {
             let alert = UIAlertController(title: "Missing Info", message: "Please select from, to and date points", preferredStyle: .alert)
             let button = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
             alert.addAction(button)
             present(alert, animated: true)
             return
         }
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let viewController = storyboard.instantiateViewController(withIdentifier: "busSeatBoard") as! ViewController
         delegate = viewController
         delegate?.sendMessage(ID: busID)
         viewController.modalPresentationStyle = .overFullScreen
         present(viewController, animated: true, completion: nil)
       }
     */
    
    func findUUID() {
        if let filteredRoutes = voyageClass?.filter({
                $0.initialPoint == selectedInitialPoint
                && $0.finishPoint == selectedFinalPoint
                && "\($0.voyageDate.day.twoDigit())-\($0.voyageDate.month.twoDigit())-\($0.voyageDate.year) \($0.voyageDate.hour.hour.twoDigit()):\($0.voyageDate.hour.minute.twoDigit())" == selectedDatePoint
            }),
           !(filteredRoutes.isEmpty) {
            let voyageID = filteredRoutes.map { $0.busID}
            busID = voyageID.first
      
        }
    }
    
    
    func createDatePoint() {
        if let count = voyageClass?.count {
            for i in 0...count - 1 {
                if let date = voyageClass?[i].voyageDate {
                    let year = date.year
                    let month = date.month
                    let day = date.day
                    let hour = date.hour.hour
                    let minute = date.hour.minute
                    let formattedMonth = String(format: "%02d", month)
                    let formattedDay = String(format: "%02d", day)
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let wholeDate = "\(formattedDay)-\(formattedMonth)-\(year) \(formattedHour):\(formattedMinute)"
                    
                    datePointSet.insert(wholeDate)
                    datePointArray = datePointSet.sorted()
                    
                }
            }
        }
        
    }
    
    
    func createInitialPoint() {
        if let count = voyageClass?.count {
            for i in 0...count - 1 {
                if let initial = voyageClass?[i].initialPoint {
                    initialPointSet.insert(initial)
                    initialPointArray = initialPointSet.sorted()
                    
                }
            }
        }
        
    }
    
    func createFinalPoint() {
        if let count = voyageClass?.count {
            for i in 0...count - 1 {
                if let final = voyageClass?[i].finishPoint {
                    finalPointSet.insert(final)
                    finalPointArray = initialPointSet.sorted()
                    
                }
            }
        }
    }
    
    func updateFinalPicker() {
        guard let selectedInitialPoint = selectedInitialPoint else {return}
        if let filteredRoutes = voyageClass?.filter({ $0.initialPoint == selectedInitialPoint }) {
            if !(filteredRoutes.isEmpty) {
                afterSelectionFinalPointsArray = filteredRoutes.map { $0.finishPoint }
                var afterSelectionSet : Set<String> = []
                afterSelectionFinalPointsArray.forEach{ element in afterSelectionSet.insert(element) }
                finalPointArray = afterSelectionSet.sorted()
            }
        }
      
    }
    
    func updateDatePicker() {
        guard let selectedInitialPoint,
             let selectedFinalPoint else {return}
        if let filteredRoutes = voyageClass?.filter({ $0.initialPoint == selectedInitialPoint && $0.finishPoint == selectedFinalPoint}) {
            if !(filteredRoutes.isEmpty) {
                let voyageDate = filteredRoutes.map { $0.voyageDate }
                var afterSelectionSet : Set<String> = []
                for i in 0...voyageDate.count - 1 {
                    let year = voyageDate[i].year
                    let month = voyageDate[i].month
                    let day = voyageDate[i].day
                    let hour = voyageDate[i].hour.hour
                    let minute = voyageDate[i].hour.minute
                    let formattedMonth = String(format: "%02d", month)
                    let formattedDay = String(format: "%02d", day)
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let wholeDate = "\(formattedDay)-\(formattedMonth)-\(year) \(formattedHour):\(formattedMinute)"
                    afterSelectionSet.insert(wholeDate)
                    datePointArray = afterSelectionSet.sorted()
                }
            }
        }
    }
    
    
    final func fillSeatGender() {
        for element in 0...voyagesSeatArray.count - 1 {
            guard let definedSeat = voyagesSeatArray[element].map({$0[0]}) as? [Int] else {return}
            let seatNumbers = Array(1...45)
            seatNumbers.forEach { seatNumber in
                guard !definedSeat.contains(seatNumber) else {return}
                voyagesSeatArray[element].append([seatNumber,Gender.empty.toString()])
                
            }
        }
        
    }
}

extension MainViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == fromPicker {
            return initialPointArray.count
        } else if pickerView == toPicker {
            return finalPointArray.count
        } else if pickerView == datePicker {
            return datePointArray.count
        }
        return 0
    }
    
   
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        guard selectedInitialPoint != nil else {
            if pickerView == fromPicker {
                if initialPointArray[row] == initialPointArray[0] {
                    return "Please select"
                }
            }
            return nil
        }
        toPicker.isUserInteractionEnabled = true
        datePicker.isUserInteractionEnabled = true
            if pickerView == fromPicker {
                //            updateFinalPicker()
                return initialPointArray[row]
            } else if pickerView == toPicker {
                //            updateInitialPicker()
                return finalPointArray[row]
            } else if pickerView == datePicker {
                return datePointArray[row]
            } else {
                return nil
            }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fromPicker {
            selectedInitialPoint = initialPointArray[row]
            updateFinalPicker()
            selectedFinalPoint = finalPointArray[0]
            updateDatePicker()
            selectedDatePoint = datePointArray[0]
            fromPicker.reloadAllComponents()
            toPicker.reloadAllComponents()
            datePicker.reloadAllComponents()
    
        } else if pickerView == toPicker {
            selectedFinalPoint = finalPointArray[row]
            updateDatePicker()
            fromPicker.reloadAllComponents()
            datePicker.reloadAllComponents()
       
        } else if pickerView == datePicker {
            selectedDatePoint = datePointArray[row]
        }
       
        findUUID()
    }
    
}

extension MainViewController {
    // creating coredata with predefined array
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
            dateFormatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
            let dateString = voyagesArray[num][2]
            if let date = dateFormatter.date(from: dateString) {
                let nsDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
                newBus.setValue(nsDate, forKey: "date")
            }
            
            for seats in voyagesSeatArray[num] {
                let seat = NSEntityDescription.insertNewObject(forEntityName: "SeatStatus",  into: context)
                seat.setValue(seats[0], forKey: "seatNumber")
                seat.setValue(seats[1], forKey: "seatGender")
                seat.setValue(newBus, forKey:  "busR")
            }
        }
        
        
        do {
            try context.save()
        } catch  {
            print("veri kaydedilemedi")
        }
    }
    
    

    // mapping data from coredata to class
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

extension Int {
    func twoDigit() -> String {
        String(format: "%02d", self)
    }
}
