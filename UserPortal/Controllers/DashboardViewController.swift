//
//  DashboardViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit

class DashboardViewController: UIViewController {
    
    var noDataFoundImageView: UIImageView?
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredName: [String] = []
    
    var mobilityAPI: MobilityAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNoDataFoundImageView()
        fetchEmployeeData()
        print(filteredName)
    }
    
    func fetchEmployeeData() {
        ApiHelper.fetchEmployeeData { [weak self] (result: Result<MobilityAPI, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let mobilityAPI):
                self.mobilityAPI = mobilityAPI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.removeNoDataFoundImageView()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
    
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
        // Remove the "No Data Found" image view from the view hierarchy
        noDataFoundImageView?.removeFromSuperview()
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

extension DashboardViewController:  UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            // Perform edit action
            completion(true)
        }
        editAction.backgroundColor = .gray // Customize the background color
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            // Perform delete action
            completion(true)
        }
        
        // Create configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false // prevents the action from being triggered by a full swipe
        
        return configuration
    }
}

