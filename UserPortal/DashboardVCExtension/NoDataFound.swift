//
//  NoDataFound.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import Foundation
import UIKit

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
