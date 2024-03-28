//
//  FetchData.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import CoreData

//GetData
extension DashboardViewController{
    
    func fetchDataAndUpdateUI(completion: (() -> Void)?) {
        // Attempt to fetch data from the API
        DataManager.shared.fetchData { result in
            switch result {
            
            case .success(let mobilityAPI):
                // Update UI with the data fetched from the API
                print(result)
                print("Data fetched:", mobilityAPI)
                self.mobilityAPI = mobilityAPI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.removeNoDataFoundImageView()
                    CustomToast.show(message: mobilityAPI.message)
                    completion?() // Call completion after updating UI if it's not nil
                }
            case .failure(let error):
                print(result)
                print("Failed to fetch data from API:", error.localizedDescription)
                // Check if there is data available in Core Data
                if let localData = DataManager.shared.fetchDataFromCoreData() {
                    // Update UI with the data fetched from Core Data
                    print("Data fetched from Core Data:", localData)
                    print("Local Data: ",localData)
                    self.mobilityAPI = localData
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.removeNoDataFoundImageView()
                        completion?() // Call completion after updating UI if it's not nil
                    }
                } else {
                    print(result)
                    // Handle case where both API and Core Data fetch failed
                    print("No data found")
                    DispatchQueue.main.async {
                        self.addNoDataFoundImageView()
                        completion?() // Call completion after updating UI if it's not nil
                    }
                }
            }
        }
    }
    
    
    func fetchUserData() {
        ApiHelper.fetchUserData { [weak self] (result: Result<MobilityAPI, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let mobilityAPI):
                self.mobilityAPI = mobilityAPI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.fetchDataAndUpdateUI(completion: nil)
                    self.removeNoDataFoundImageView()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
                self.fetchDataAndUpdateUI(completion: nil)
            }
        }
    }
}
