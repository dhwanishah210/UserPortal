//
//  Search.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import UIKit
import CoreData

//SEARCH
extension DashboardViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all data
            fetchUserData()
        } else {
            // Filter data based on search text
            searchData(with: searchText)
        }
    }
    
    @objc func handleTap() {
            searchBar.resignFirstResponder() // Dismiss the keyboard associated with the search bar
        }
    
    func searchData(with searchText: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
        
        // Create compound predicate to search in name, email, and mobile fields
        let predicate = NSPredicate(format: "name CONTAINS[c] %@ OR email CONTAINS[c] %@ OR mobile CONTAINS[c] %@", searchText, searchText, searchText)
        fetchRequest.predicate = predicate
        
        do {
            // Fetch filtered CoreData objects
            let filteredData = try context.fetch(fetchRequest)
            
            // Convert fetched DbData objects to Data objects
            let convertedData = filteredData.compactMap { dbData -> Data? in
                // Convert DbData to Data object as per your requirement
                return convertDbDataToData(dbData)
            }
            
            // Update mobilityAPI data with converted Data objects
            self.mobilityAPI?.data = convertedData
            
            // Reload table view to reflect the changes
            tableView.reloadData()
        } catch {
            print("Error fetching filtered data: \(error.localizedDescription)")
        }
    }
    
}
