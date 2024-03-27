//
//  DashboardViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var noDataFoundImageView: UIImageView?
    var mobilityAPI: MobilityAPI?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnFilter: UIButton!
    
    let dF = DateFormatter()
    
    let dateFormatter = DateFormatter()
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNoDataFoundImageView()
        fetchEmployeeData()
    }
    
}

//CELL of Table
extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobilityAPI?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        
        if let data = mobilityAPI?.data?[indexPath.row] {
            cell.lblName?.text = "\(data.name ?? "")"
            cell.lblEmail?.text = "\(data.email ?? "")"
        }
        
        return cell
    }
}

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = mobilityAPI?.data?[indexPath.row] else {
            return
        }
        
        // Instantiate ProfileViewController from storyboard
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileViewController else {
            return
        }
        
        // Pass the selected data to ProfileViewController
        profileVC.userData = data
        
        // Present ProfileViewController modally
        present(profileVC, animated: true, completion: nil)
    }
    
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
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Gender"
            textField.text = String(data.gender!)
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
                            self.fetchEmployeeData()
                        } else {
                            print("Data not found in database.")
                        }
                    } catch {
                        print("Error updating data: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Failed to update user data: \(error)")
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
                self.fetchEmployeeData()
            case .failure(let error):
                print("Failed to delete user: \(error)")
            }
        }
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
        ApiHelper.fetchUserData { [weak self] (result: Result<MobilityAPI, Error>) in
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
                                self!.fetchEmployeeData()
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


//FILTERDATA
extension DashboardViewController{
    @IBAction func filterData(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.sourceView = btnFilter
        alertController.popoverPresentationController?.sourceRect = btnFilter.bounds
        alertController.popoverPresentationController?.permittedArrowDirections = [.down]
        
        alertController.addAction(UIAlertAction(title: "Ascending", style: .default, handler: { (_) in
            // Fetch CoreData objects sorted by name in ascending order
            self.fetchAndSortData(sortKey: "name", ascending: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Descending", style: .default, handler: { (_) in
            // Fetch CoreData objects sorted by name in descending order
            self.fetchAndSortData(sortKey: "name", ascending: false)
        }))
        
        alertController.addAction(UIAlertAction(title: "Last Inserted", style: .default, handler: { (_) in
            // Sort data in ascending order
            self.fetchAndSortData(sortKey: "createdAt", ascending: false)
            self.tableView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Last Modified", style: .default, handler: { (_) in
            // Sort data in ascending order
            self.fetchAndSortData(sortKey: "updatedAt", ascending: false)
            self.tableView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func fetchAndSortData(sortKey: String, ascending: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
        
        // Sort descriptors based on sort key and order
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            // Fetch sorted CoreData objects
            let sortedData = try context.fetch(fetchRequest)
            
            // Convert fetched DbData objects to Data objects
            let convertedData = sortedData.compactMap { dbData -> Data? in
                // Convert DbData to Data object as per your requirement
                return convertDbDataToData(dbData)
            }
            
            // Update mobilityAPI data with sorted and converted CoreData objects
            self.mobilityAPI?.data = convertedData
            
            // Reload table view to reflect the changes
            self.tableView.reloadData()
        } catch {
            print("Error fetching sorted data: \(error.localizedDescription)")
        }
    }
    
    func convertDbDataToData(_ dbData: DbData) -> Data? {
        // Convert DbData to Data object as per your requirement
        // For example:
        let data = Data(name: dbData.name, email: dbData.email)
        return data
    }
    
}


//SEARCH
extension DashboardViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all data
            fetchEmployeeData()
        } else {
            // Filter data based on search text
            searchData(with: searchText)
        }
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
