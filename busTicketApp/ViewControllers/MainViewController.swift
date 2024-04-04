//
//  MainViewController.swift
//  busTicketApp
//
//  Created by Ezgi Sümer Günaydın on 4.04.2024.
//

import UIKit

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selectedInitialPoint: String?
    var routes: [[String]] = [
        [ "Istanbul", "Ankara", "87435A64-C26D-4028-AE4A-01DDC41F0A7E"],
        [ "Sinop", "Trabzon", "1EB7525A-BD36-45D3-9F6A-AFDA40ECA00"],
        [ "Sinop", "Istanbul", "1EB7525A-BD36-45D3-9F6A-AFDA40ECA00"]
    ]
    var finalPointsArray: [String] = []
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var chooseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromPicker.delegate = self
        fromPicker.dataSource = self
        
        toPicker.delegate = self
        toPicker.dataSource = self
        toPicker.isHidden = true
        

    }


    @IBAction func chooseButtonTapped(_ sender: UIButton) {
       
      }
  
    

}

extension MainViewController {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == fromPicker {
            return routes.count // fromPicker için başlangıç noktalarını döndür
        } else if pickerView == toPicker {
            return finalPointsArray.count
        }
        return 0
      
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == fromPicker {
            return routes[row][0] // fromPicker için başlangıç noktalarını döndür
        } else if pickerView == toPicker {

            updateToPicker()
         return finalPointsArray[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fromPicker {
            selectedInitialPoint = routes[row][0]
            toPicker.isHidden = false
            updateToPicker()
            toPicker.reloadAllComponents()
        }
          
         
          
    }
    
    func updateToPicker() {
          guard let selectedInitialPoint = selectedInitialPoint else {
              print("Lütfen başlangıç noktası seçiniz.")
              return
          }
          
          // Seçilen başlangıç noktasına göre filtreleme yap ve toPicker'ı güncelle
        let filteredRoutes = routes.filter { $0[0] == selectedInitialPoint }
             if !filteredRoutes.isEmpty {
                 finalPointsArray = filteredRoutes.map { $0[1] }
//                 toPicker.isHidden = false
//                 toPicker.reloadAllComponents()
                 print("finalpoint guncellendi \(finalPointsArray)")
             } else {
                 toPicker.isHidden = true
             }
         }
      }

