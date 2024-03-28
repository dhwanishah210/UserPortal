//
//  AddUserAction.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import UIKit
import CoreData

//AddUser
extension DashboardViewController{
    @IBAction func addUser(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Data", message: "Add data for ", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Gender"
            //textField.keyboardType = .numberPad
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Mobile"
            textField.keyboardType = .numberPad
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard self != nil else { return }
            
            // Access text fields and retrieve user input
            let nameTextField = alertController.textFields?[0]
            let genderTextField = alertController.textFields?[1]
            let mobileTextField = alertController.textFields?[2]
            let emailTextField = alertController.textFields?[3]
            
            guard let name = nameTextField?.text,
                  let genderText = genderTextField?.text,
                  let gender = Int(genderText),
                  let mobile = mobileTextField?.text,
                  let email = emailTextField?.text else {
                // Handle invalid input or empty fields
                return
            }
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            // Now make a network request to add the user data to the API
            let parameters: [String: Any] = [
                "name": name,
                "gender": gender,
                "mobile": mobile,
                "email": email
            ]
            
            // Make a POST request to the API endpoint to add user data
            ApiHelper.addUser(parameters: parameters) { result in
                switch result {
                case .success(let response):
                    print("User added successfully to the API: \(response)")
                    if let responseData = response.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        // Access the 'data' field from the JSON dictionary
                        if let data = json["data"] as? Int {
                            print("Data from response: \(data)")
                            let context = appDelegate.persistentContainer.viewContext
                            
                            self!.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Format for full date and time
                            let dateTimeString = self!.dateFormatter.string(from: self!.currentDate)
                            
                            // Create a new DbData object and insert it into Core Data
                            let dbDataObject = DbData(context: context)
                            //DataManager.count+=1
                            dbDataObject.id = Int16(data)
                            dbDataObject.name = name
                            dbDataObject.gender = Int16(gender)
                            dbDataObject.mobile = mobile
                            dbDataObject.email = email
                            dbDataObject.createdAt = dateTimeString
                            
                            
                            // Save changes to Core Data
                            do {
                                try context.save()
                                print("Data saved successfully")
                                self!.fetchUserData()
                            } catch {
                                print("Error saving data: \(error.localizedDescription)")
                            }
                        } else {
                            print("Failed to extract data from response.")
                        }
                    } else {
                        print("Failed to parse JSON response.")
                    }
                case .failure(let error):
                    print("Failed to add user to API: \(error)")
                // Handle failure if needed
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
