//
//  DataManager.swift
//  UserPortal
//
//  Created by Dhwani Shah on 21/03/24.
//

import UIKit
import Foundation
import CoreData

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    

    func fetchData(completion: @escaping (Result<MobilityAPI, Error>) -> Void) {
        
        // First attempt to fetch data from the API
        ApiHelper.fetchEmployeeData { result in
            switch result {
            case .success(let mobilityAPI):
                // If data is successfully fetched from the API, insert it into Core Data
                self.insertDataIntoCoreData(mobilityAPI: mobilityAPI)
                completion(.success(mobilityAPI)) // Return the fetched data
            case .failure(let apiError):
                print("API Error: \(apiError)")
                // If fetching data from the API fails, attempt to fetch from Core Data
                guard let fetchedData = self.fetchDataFromCoreData() else {
                    completion(.failure(apiError)) // If no data is available in Core Data, return API error
                    return
                }
                // If data is successfully fetched from Core Data, return it
                completion(.success(fetchedData))
            }
        }
    }

    func fetchDataFromCoreData() -> MobilityAPI? {
        var mobilityAPI: MobilityAPI?
        DispatchQueue.main.sync {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
            
            do {
                let dataObjects = try context.fetch(fetchRequest)
                
                // Check if there are no rows present in Core Data
                if dataObjects.isEmpty {
                    return
                }
                
                // Convert fetched Core Data objects to MobilityAPI model
                let data = dataObjects.compactMap { dbData -> Data? in
                    // Map DbData to Data model
                    return Data(id: Int(dbData.id), name: dbData.name, gender: Int(dbData.gender), email: dbData.email, mobile: dbData.mobile, createdAt: dbData.createdAt, updatedAt: dbData.updatedAt)
                }
                
                // Construct MobilityAPI model with the fetched data
                mobilityAPI = MobilityAPI(status: 200, data: data, message: "Data fetched from Core Data")
            } catch {
                print("Error fetching data from Core Data: \(error.localizedDescription)")
            }
        }
        return mobilityAPI
    }



    
    private func insertDataIntoCoreData(mobilityAPI: MobilityAPI) {
        var count: Int = 1
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let persistentContainer = appDelegate.persistentContainer
            if let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
                print("Database Path: \(storeURL)")
            } else {
                print("Database path not found")
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            for dataItem in mobilityAPI.data ?? [] {
                let dbDataObject = DbData(context: context)
                dbDataObject.id = Int16(count)
                dbDataObject.name = dataItem.name
                dbDataObject.gender = Int16(dataItem.gender ?? 0)
                dbDataObject.email = dataItem.email
                dbDataObject.mobile = dataItem.mobile
                dbDataObject.createdAt = dataItem.createdAt
                dbDataObject.updatedAt = dataItem.updatedAt
            }
            
            do {
                try context.save()
                count+=1
                print("Data saved successfully")

            } catch {
                print("Error saving data: \(error.localizedDescription)")
            }
        }
    }

    
    // Other data management methods...
}

