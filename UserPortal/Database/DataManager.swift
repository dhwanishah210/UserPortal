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
    
    static var count: Int = 0
    

    func fetchData(completion: @escaping (Result<MobilityAPI, Error>) -> Void) {
        
        // First attempt to fetch data from the API
        ApiHelper.fetchUserData { result in
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
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let context = appDelegate.persistentContainer.viewContext
            
            // Fetch existing DbData objects with the same IDs as in the MobilityAPI
            let existingIds = Set(mobilityAPI.data?.compactMap { $0.id } ?? [])
            let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", existingIds)
            
            do {
                let existingObjects = try context.fetch(fetchRequest)
                let existingIdsSet = Set(existingObjects.map { $0.id })

                for dataItem in mobilityAPI.data ?? [] {
                    // Check if the object with the same ID already exists
                    if existingIdsSet.contains(Int16(dataItem.id!)) {
                        print("Data with ID \(String(describing: dataItem.id)) already exists in the database. Skipping insertion.")
                        continue
                    }

                    let dbDataObject = DbData(context: context)
                    dbDataObject.id = Int16(dataItem.id!)
                    dbDataObject.name = dataItem.name
                    dbDataObject.gender = Int16(dataItem.gender ?? 0)
                    dbDataObject.email = dataItem.email
                    dbDataObject.mobile = dataItem.mobile
                    dbDataObject.createdAt = dataItem.createdAt
                    dbDataObject.updatedAt = dataItem.updatedAt
                }

                try context.save()
                print("Data saved successfully")
            } catch {
                print("Error saving data: \(error.localizedDescription)")
            }
        }
    }

    func deleteUserDataFromDatabase(id: Int) {
        // Access the managed object context from the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext

        // Fetch the corresponding DbData object from the database using its unique identifier (ID)
        let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)

        do {
            if let dbDataObject = try context.fetch(fetchRequest).first {
                // Delete the DbData object from the database
                context.delete(dbDataObject)

                // Save the changes to the database
                try context.save()
                print("User data deleted from the database.")
            } else {
                print("User data not found in the database.")
            }
        } catch {
            print("Error deleting user data from the database: \(error.localizedDescription)")
        }
    }
    
    // Other data management methods...
}

