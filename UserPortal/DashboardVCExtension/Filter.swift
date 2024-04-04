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
            self.fetchAndSortData(sortKey: "name", ascending: false)
            saveFilter = "name"
            key = false
            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
        }))
        
        alertController.addAction(UIAlertAction(title: "Last Inserted", style: .default, handler: { (_) in
            self.fetchAndSortData(sortKey: "createdAt", ascending: false)
            saveFilter = "createdAt"
            key = false
            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
        }))
        
        alertController.addAction(UIAlertAction(title: "Last Modified", style: .default, handler: { (_) in
            self.fetchAndSortData(sortKey: "updatedAt", ascending: false)
            saveFilter = "updatedAt"
            key = false
            UserDefaults.standard.set(saveFilter, forKey: "sortKey")
            UserDefaults.standard.set(key, forKey: "value")
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
            
            // Sort descriptors based on sort key and order
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending) // <- Update ascending to true or false
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                // Fetch sorted CoreData objects
                let sortedData = try context.fetch(fetchRequest)
                
                // Convert fetched DbData objects to Data objects
                let convertedData = sortedData.compactMap { dbData -> Data? in
                    // Convert DbData to Data object as per your requirement
                    return self.convertDbDataToData(dbData)
                }
                
                // Update mobilityAPI data with sorted and converted CoreData objects
                self.mobilityAPI?.data = convertedData
                
                // Reload table view to reflect the changes
                self.tableView.reloadData()
                
            } catch {
                print("Error fetching sorted data: \(error.localizedDescription)")
            }
        }
    }

    
    func convertDbDataToData(_ dbData: DbData) -> Data? {
        // Convert DbData to Data object as per your requirement

        let data = Data(id: Int(dbData.id), name: dbData.name, gender: Int(dbData.gender), email: dbData.email, mobile: dbData.mobile)
        return data
    }
    
}
