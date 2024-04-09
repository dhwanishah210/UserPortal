//
//  Filter.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import UIKit
import CoreData

var saveFilter: String = "name"
var key: Bool = true

//FILTERDATA
extension DashboardViewController{
    
    @IBAction func filterData(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.sourceView = btnFilter
        alertController.popoverPresentationController?.sourceRect = btnFilter.bounds
        alertController.popoverPresentationController?.permittedArrowDirections = [.down]
        
        alertController.addAction(UIAlertAction(title: "Ascending(A-Z)", style: .default, handler: { (_) in
            self.fetchAndSortData(sortKey: "name", ascending: true)
            saveFilter = "name"
            key = true
            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
        }))
        
        alertController.addAction(UIAlertAction(title: "Descending(Z-A)", style: .default, handler: { (_) in
            
            saveFilter = "name"
            key = false
            self.fetchAndSortData(sortKey: saveFilter, ascending: key)

            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
        }))
        
        alertController.addAction(UIAlertAction(title: "Last Inserted", style: .default, handler: { (_) in
            
            saveFilter = "createdAt"
            key = false
            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
            self.fetchAndSortData(sortKey: "createdAt", ascending: false)
        }))
        
        alertController.addAction(UIAlertAction(title: "Last Modified", style: .default, handler: { (_) in
            
            saveFilter = "updatedAt"
            key = false
            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
            self.fetchAndSortData(sortKey: "updatedAt", ascending: false)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func fetchAndSortData(sortKey: String, ascending: Bool) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
            
            do {
                // Fetch data from Core Data
                var fetchedData = try context.fetch(fetchRequest)
                
                // Sort the array manually
                fetchedData.sort { (data1, data2) -> Bool in
                    switch sortKey {
                    case "name":
                        let name1 = data1.name!.trimmingCharacters(in: .whitespaces)
                        let name2 = data2.name!.trimmingCharacters(in: .whitespaces)
                        if ascending {
                            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
                        } else {
                            return name1.localizedCaseInsensitiveCompare(name2) == .orderedDescending
                        }
                    case "createdAt":
                        if ascending {
                            return data1.createdAt! < data2.createdAt!
                        } else {
                            return data1.createdAt! > data2.createdAt!
                        }
                    case "updatedAt":
                        if ascending {
                            return data1.updatedAt! < data2.updatedAt!
                        } else {
                            return data1.updatedAt! > data2.updatedAt!
                        }
                    default:
                        // Handle unknown sort key
                        return false
                    }
                }
                
                // Convert fetched DbData objects to Data objects
                let convertedData = fetchedData.compactMap { dbData -> Data? in
                    return self.convertDbDataToData(dbData)
                }
                
                self.mobilityAPI?.data = convertedData
                self.tableView.reloadData()
                
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }

    
    func convertDbDataToData(_ dbData: DbData) -> Data? {
        // Convert DbData to Data object as per your requirement
        let data = Data(id: Int(dbData.id), name: dbData.name, gender: Int(dbData.gender), email: dbData.email, mobile: dbData.mobile)
        return data
    }
    
}
