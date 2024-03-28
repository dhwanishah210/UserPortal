//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit

class ProfileViewController: UIViewController, ProfileImageDelegate {
    
    func didSelectImage(_ image: UIImage) {
        profileImageView.image = image
    }
    

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    
    var userData: Data?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        if let userData = userData {
            lblName.text = "\(userData.name ?? "")"
            lblEmail.text = "\(userData.email ?? "")"
            lblMobile.text = "\(userData.mobile ?? "")"
            //lblGender.text = "Gender: \(String(userData.gender!) )"

        }

    }

    @IBAction func btnLogout(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "DashboardVC") as! DashboardViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: false)
    }
}
