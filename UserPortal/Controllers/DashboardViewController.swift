//
//  DashboardViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit
import CoreData
import Network

class DashboardViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var monitor = NWPathMonitor()
    var refreshControl = UIRefreshControl()
    var noDataFoundImageView: UIImageView?
    var mobilityAPI: MobilityAPI?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnFilter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        fetchUserData()
        
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                DispatchQueue.main.async {
                    self.showNetworkUnavailableMessage()
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func refreshData(_ sender: Any) {
        DataManager.shared.processPendingDeleteRequests()
        fetchUserData()
    }
    
    func showNetworkUnavailableMessage() {
        let alertController = UIAlertController(title: "Network Unavailable", message: "Please enable Wi-Fi or mobile data to access the internet.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        monitor.cancel()
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
            cell.lblMobile?.text = "\(data.mobile ?? "")"
        }
        
        return cell
    }
}

//EDIT and DELETE
extension DashboardViewController: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
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
            self?.editData(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .gray
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            
            let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            }
            alertController.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteData(at: indexPath)
                completion(true)
            }
            alertController.addAction(deleteAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func editData(at indexPath: IndexPath) {
        guard let data = mobilityAPI?.data?[indexPath.row] else {
            return
        }
        let addUserController = storyboard?.instantiateViewController(withIdentifier: "AddUserVC") as! AddUserViewController
        addUserController.editMode = true
        addUserController.dataToEdit = data
        navigationController?.pushViewController(addUserController, animated: true)
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
                
                DispatchQueue.main.async {
                    DataManager.shared.deleteUserDataFromDatabase(id: data.id!)
                    print("User deleted from Local Database: \(error)")
                    self.fetchUserData()
                    DataManager.shared.storeDeleteRequest(parameters: parameters)
                }
            }
        }
    }
}


//AddUser
extension DashboardViewController{
    @IBAction func addUser(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddUserVC") as! AddUserViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//SEARCH
extension DashboardViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all data
            fetchUserData()
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
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@ OR email CONTAINS[c] %@ OR mobile CONTAINS[c] %@", searchText, searchText, searchText)
        fetchRequest.predicate = predicate
        
        do {
            // Fetch filtered CoreData objects
            let filteredData = try context.fetch(fetchRequest)
            
            let convertedData = filteredData.compactMap { dbData -> Data? in
                return convertDbDataToData(dbData)
            }
            self.mobilityAPI?.data = convertedData
            tableView.reloadData()
            
        } catch {
            print("Error fetching filtered data: \(error.localizedDescription)")
        }
    }
}

//GetData
extension DashboardViewController{
    
    func fetchUserData() {
        ApiHelper.fetchUserData { [weak self] (result: Result<MobilityAPI, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let mobilityAPI):
                DataManager.shared.clearAllData()
                self.mobilityAPI = mobilityAPI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.fetchDataAndUpdateUI(completion: nil)
                    self.removeNoDataFoundImageView()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
                self.fetchDataAndUpdateUI(completion: nil)
                //self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchDataAndUpdateUI(completion: (() -> Void)?) {
        // Attempt to fetch data from the API
        DataManager.shared.fetchData { result in
            switch result {
            
            case .success(let mobilityAPI):
                // Update UI with the data fetched from the API
                print("Data fetched:", mobilityAPI)
                if mobilityAPI.message == "No Data Found"{
                    DispatchQueue.main.async {
                        self.addNoDataFoundImageView()
                        completion?()
                    }
                }else{
                    self.mobilityAPI = mobilityAPI
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.fetchAndSortData(sortKey: UserDefaults.standard.string(forKey: "sortKey") ?? "name", ascending: UserDefaults.standard.bool(forKey: "value"))
                        self.removeNoDataFoundImageView()
                        self.refreshControl.endRefreshing()
                        //CustomToast.show(message: mobilityAPI.message)
                        completion?()
                    }}
            case .failure(let error):
                print("Failed to fetch data from API:", error.localizedDescription)
                // Check if there is data available in Core Data
                if let localData = DataManager.shared.fetchDataFromCoreData() {
                    // Update UI with the data fetched from Core Data
                    print("Data fetched from Core Data:", localData)
                    print("Local Data: ",localData)
                    self.mobilityAPI = localData
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        let storedValue = true
                        self.fetchAndSortData(sortKey: storedKey!, ascending: storedValue)
                        self.refreshControl.endRefreshing()
                        self.removeNoDataFoundImageView()
                        completion?()
                    }
                } else {
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
}


//Animation
extension DashboardViewController {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: false)
    }
}

