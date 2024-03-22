//
//  DashboardViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController {
    
    var noDataFoundImageView: UIImageView?
    var mobilityAPI: MobilityAPI?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnFilter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNoDataFoundImageView()
        fetchEmployeeData()
    }

}

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobilityAPI?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        
        if let data = mobilityAPI?.data?[indexPath.row] {
            cell.lblName?.text = "Name: \(data.name ?? "")"
            cell.lblEmail?.text = "Email : \(data.email ?? "")"
        }
        
        return cell
    }
}

extension DashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            // Perform edit action
            self?.editData(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .gray // Customize the background color
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            // Perform delete action
            self?.deleteData(at: indexPath)
            completion(true)
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (_) in
            guard let nameTextField = alertController.textFields?[0],
                  let emailTextField = alertController.textFields?[1],
                  let newName = nameTextField.text,
                  let newEmail = emailTextField.text else {
                return
            }
            
            // Update the data
            self?.updateData(at: indexPath, newName: newName, newEmail: newEmail)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateData(at indexPath: IndexPath, newName: String, newEmail: String) {
        guard let data = mobilityAPI?.data?[indexPath.row] else {
            return
        }
        
        // Access the managed object context from the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Fetch the corresponding DbData object from the database using its unique identifier (ID)
        let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", data.id ?? 0)
        print(data.id ?? 0)
        do {
            if let dbDataObject = try context.fetch(fetchRequest).first {
                // Update the attributes of the DbData object with the new values
                dbDataObject.name = newName
                dbDataObject.email = newEmail
                
                // Save the changes to the database
                try context.save()
                
                // Optionally, you can also update the local data source with the updated values
                mobilityAPI?.data?[indexPath.row].name = newName
                mobilityAPI?.data?[indexPath.row].email = newEmail
            } else {
                print("Data not found in database.")
            }
        } catch {
            print("Error updating data: \(error.localizedDescription)")
        }
    }

    
    func deleteData(at indexPath: IndexPath) {
        // Perform the delete operation in your data model or database
        // Update the UI if needed
        // Reload table view if necessary
    }
}


//GetData
extension DashboardViewController{
    
    func fetchDataAndUpdateUI() {
        // Attempt to fetch data from the API
        DataManager.shared.fetchData { result in
            switch result {
            
            case .success(let mobilityAPI):
                // Update UI with the data fetched from the API
                print(result)
                print("Data fetched from API:", mobilityAPI)
                self.mobilityAPI = mobilityAPI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.removeNoDataFoundImageView()
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
                    }
                } else {
                    print(result)
                    // Handle case where both API and Core Data fetch failed
                    print("No data found")
                    DispatchQueue.main.async {
                        self.addNoDataFoundImageView()
                    }
                }
            }
        }
    }
    
    func fetchEmployeeData() {
        ApiHelper.fetchEmployeeData { [weak self] (result: Result<MobilityAPI, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let mobilityAPI):
                self.mobilityAPI = mobilityAPI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.fetchDataAndUpdateUI()
                    self.removeNoDataFoundImageView()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
                self.fetchDataAndUpdateUI()
            }
        }
    }
}

//AddUser
extension DashboardViewController{
    @IBAction func addUser(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Data", message: "Add data for ", preferredStyle: .alert)
                
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Gender"
            textField.keyboardType = .numberPad
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
            
            // Access the managed object context from the app delegate
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            // Create a new DbData object and insert it into Core Data
            let dbDataObject = DbData(context: context)
            dbDataObject.name = name
            dbDataObject.gender = Int16(gender)
            dbDataObject.mobile = mobile
            dbDataObject.email = email
            
            // Save changes to Core Data
            do {
                try context.save()
                print("Data saved successfully")
                self!.fetchEmployeeData()
            } catch {
                print("Error saving data: \(error.localizedDescription)")
            }
            
            // Optionally, you can update UI or perform any additional actions
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//NoDataFound Image
extension DashboardViewController{
    func addNoDataFoundImageView() {
        // Create and configure the "No Data Found" image view
        let image = UIImage(named: "noDataFound")
        noDataFoundImageView = UIImageView(image: image)
        noDataFoundImageView?.contentMode = .scaleAspectFit
        noDataFoundImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the image view to the view hierarchy
        if let imageView = noDataFoundImageView {
            view.addSubview(imageView)
            
            // Add constraints to center the image view vertically and horizontally
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16), // Ensure leading edge is at least 16 points away from the screen edge
                imageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16), // Ensure trailing edge is at most 16 points away from the screen edge
                imageView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 16), // Ensure top edge is at least 16 points away from the screen edge
                imageView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16) // Ensure bottom edge is at most 16 points away from the screen edge
            ])
        }
    }
    

    func removeNoDataFoundImageView() {
        noDataFoundImageView?.removeFromSuperview()
    }
}
