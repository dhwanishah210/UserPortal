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
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
            
            do {
                let dataObjects = try context.fetch(fetchRequest)
                
                // If there are no rows present in Core Data, fetch data from the API
                if dataObjects.isEmpty {
                    ApiHelper.fetchUserData { result in
                        switch result {
                        case .success(let mobilityAPI):
                            // If data is successfully fetched from the API, insert it into Core Data
                            self.insertDataIntoCoreData(mobilityAPI: mobilityAPI)
                            completion(.success(mobilityAPI)) // Return the fetched data
                        case .failure(let apiError):
                            print("API Error: \(apiError)")
                            completion(.failure(apiError)) // Return API error
                        }
                    }
                } else {
                    // If data exists in Core Data, fetch it and return
                    guard let fetchedData = self.fetchDataFromCoreData() else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data from Core Data"])
                        completion(.failure(error)) // Return error if fetching from Core Data fails
                        return
                    }
                    completion(.success(fetchedData)) // Return fetched data from Core Data
                }
            } catch {
                print("Error fetching data from Core Data: \(error.localizedDescription)")
                completion(.failure(error)) // Return error if fetching from Core Data fails
            }
        }
    }
    
    
    func fetchDataFromCoreData() -> MobilityAPI? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
        
        do {
            let dataObjects = try context.fetch(fetchRequest)
            // Check if there are no rows present in Core Data
            if dataObjects.isEmpty {
                DashboardViewController().addNoDataFoundImageView()
                return nil
            }
            
            // Convert fetched Core Data objects to MobilityAPI model
            let data = dataObjects.compactMap { dbData -> Data? in
                // Map DbData to Data model
                return Data(id: Int(dbData.id), name: dbData.name, gender: Int(dbData.gender), email: dbData.email, mobile: dbData.mobile, createdAt: dbData.createdAt, updatedAt: dbData.updatedAt)
            }
            
            // Construct MobilityAPI model with the fetched data
            return MobilityAPI(status: 200, data: data, message: "Data fetched from Core Data")
            
        } catch {
            print("Error fetching data from Core Data: \(error.localizedDescription)")
            return nil
        }
    }
    

    
    func insertDataIntoCoreData(mobilityAPI: MobilityAPI) {
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
        
        // Fetch the corresponding DbData object from the database using its ID
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
    
    func clearAllData() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DbData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("All data cleared from CoreData")
            } catch {
                print("Error clearing data from CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func storeDeleteRequest(parameters: [String: Any]) {
            // Store the delete request locally for future processing
            // For example, you can use UserDefaults or CoreData to store the delete requests
            // Here, I'm just demonstrating with UserDefaults
            
            var deleteRequests = UserDefaults.standard.array(forKey: "DeleteRequests") as? [[String: Any]] ?? []
            deleteRequests.append(parameters)
            UserDefaults.standard.set(deleteRequests, forKey: "DeleteRequests")
        print(deleteRequests)
        }

    func processPendingDeleteRequests() {
        let deleteRequests = UserDefaults.standard.array(forKey: "DeleteRequests") as? [[String: Any]] ?? []

        for request in deleteRequests {
            ApiHelper.deleteUser(parameters: request) { result in
                switch result {
                case .success(let response):
                    print("User deleted successfully: \(response)")
                    // Remove the processed delete request
                    self.removeProcessedDeleteRequest(request)
                case .failure(let error):
                    print("Failed to delete user from API: \(error.localizedDescription)")
                    // Handle the failure scenario here if needed
                }
            }
        }
    }

    func removeProcessedDeleteRequest(_ request: [String: Any]) {
        if var deleteRequests = UserDefaults.standard.array(forKey: "DeleteRequests") as? [[String: Any]] {
            for (index, storedRequest) in deleteRequests.enumerated() {
                // Check if the dictionaries have the same keys
                let keysEqual = storedRequest.keys.sorted() == request.keys.sorted()
                
                // Check if the dictionaries have the same values for each key
                let valuesEqual = storedRequest.allSatisfy { key, value in
                    return request[key] as? AnyHashable == value as? AnyHashable
                }
                
                if keysEqual && valuesEqual {
                    deleteRequests.remove(at: index)
                    UserDefaults.standard.set(deleteRequests, forKey: "DeleteRequests")
                    break // Break out of the loop once the request is removed
                }
            }
        }
    }



}

