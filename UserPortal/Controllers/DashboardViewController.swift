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
        searchBar.delegate = self
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        fetchUserData()
        //let filterSettings = retrieveFilterSettings()
        //fetchAndSortData(sortKey: filterSettings.sortKey, ascending: filterSettings.ascending)
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




