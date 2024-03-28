//
//  Loader.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import UIKit

//Loader
extension DashboardViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        let loader = self.loader()
        
        // Fetch data and update UI
        fetchDataAndUpdateUI {
            // Stop the loader after updating UI
            self.stopLoader(loader: loader)
        }
    }
    
    func loader() -> UIAlertController {
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.large
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            return alert
        }
        
        func stopLoader(loader : UIAlertController) {
            DispatchQueue.main.async {
                loader.dismiss(animated: true, completion: nil)
            }
        }

}
