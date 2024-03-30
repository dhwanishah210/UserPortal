//
//  AddUserAction.swift
//  UserPortal
//
//  Created by Dhwani Shah on 28/03/24.
//

import UIKit
import CoreData

//AddUser
extension DashboardViewController{
    
    @IBAction func addUser(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddUserVC") as! AddUserViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
