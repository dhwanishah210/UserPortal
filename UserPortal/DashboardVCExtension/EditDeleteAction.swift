//
//  EditDeleteAction.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import UIKit
import CoreData

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = mobilityAPI?.data?[indexPath.row] else {
            return
        }

        let vc = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
        // Pass the selected data to ProfileViewController
        vc.userData = data
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            // Perform edit action
            self?.editData(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .gray // Customize the background color
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            
            let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false) // Indicate deletion action is cancelled
            }
            alertController.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                // Perform delete action
                self.deleteData(at: indexPath)
                completion(true)
            }
            alertController.addAction(deleteAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        // Create configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false // prevents the action from being triggered by a full swipe
        
        return configuration
    }
    
    func editData(at indexPath: IndexPath) {
        
        guard let data = mobilityAPI?.data?[indexPath.row] else {
            return
        }
        
        let alertController = UIAlertController(title: "Edit Data", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = data.name
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.text = data.email
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Gender"
            //textField.text = String(data.gender!)
            if(data.gender! == 1){
                textField.text = "Female"
            }else{
                textField.text = "Male"
            }
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Mobile"
            textField.text = data.mobile
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (_) in
            guard let nameTextField = alertController.textFields?[0],
                  let emailTextField = alertController.textFields?[1],
                  let genderTextField = alertController.textFields?[2],
                  let mobileTextField = alertController.textFields?[3],
                  let newName = nameTextField.text,
                  let newEmail = emailTextField.text,
                  let newGender = genderTextField.text,
                  let newMobile = mobileTextField.text else {
                return
            }
            
            // Update the data
            self?.updateData(id: data.id!, newName: newName, newEmail: newEmail, newGender: Int16(newGender) ?? 0, newMobile: newMobile)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateData(id: Int, newName: String, newEmail: String, newGender: Int16, newMobile: String) {
        
        let parameters: [String: Any] = [
            "id": id,
            "name": newName,
            "gender": newGender,
            "email": newEmail,
            "mobile": newMobile
        ]
        
        ApiHelper.updateUser(parameters: parameters) { result in
            switch result {
            case .success(let response):
                print("User data updated successfully: \(response)")
                
                // Access the managed object context from the app delegate
                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    let context = appDelegate.persistentContainer.viewContext
                    self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Format for full date and time
                    let dateTimeString = self.dateFormatter.string(from: self.currentDate)
                    
                    // Fetch the corresponding DbData object from the database using its unique identifier (ID)
                    let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
                    print(id)
                    do {
                        if let dbDataObject = try context.fetch(fetchRequest).first {
                            // Update the attributes of the DbData object with the new values
                            dbDataObject.name = newName
                            dbDataObject.email = newEmail
                            dbDataObject.updatedAt = dateTimeString
                            
                            // Save the changes to the database
                            try context.save()
                            self.fetchUserData()
                        } else {
                            print("Data not found in database.")
                        }
                    } catch {
                        print("Error updating data: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Failed to update user data: \(error)")
                CustomToast.show(message: error.localizedDescription)
            }
        }
    }
    
    
    func deleteData(at indexPath: IndexPath) {
        
        guard let data = mobilityAPI?.data?[indexPath.row] else {
            return
        }
        let parameters: [String: Any] = ["id": data.id as Any]
        
        // Call the API to delete the user
        ApiHelper.deleteUser(parameters: parameters) { result in
            switch result {
            case .success(let response):
                print("User deleted successfully: \(response)")
                // If the API call is successful, delete the corresponding user from the database
                DispatchQueue.main.async {
                    DataManager.shared.deleteUserDataFromDatabase(id: data.id!)
                }
                self.fetchUserData()
            case .failure(let error):
                CustomToast.show(message: error.localizedDescription)
                print("Failed to delete user: \(error)")
                
            }
        }
    }
}
