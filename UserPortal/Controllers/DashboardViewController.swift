//
//  DashboardViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit
import CoreData
import Network

var storedKey = UserDefaults.standard.string(forKey: "sortKey")
var storedValue = UserDefaults.standard.bool(forKey: "value")

class DashboardViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let monitor = NWPathMonitor()
    
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
        
        UserDefaults.standard.set("name", forKey: "sortKey")
                
        fetchUserData()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                DispatchQueue.main.async {
                    self.showNetworkUnavailableMessage()
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
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
        }
        
        return cell
    }
}

extension DashboardViewController {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: false)
    }
}
