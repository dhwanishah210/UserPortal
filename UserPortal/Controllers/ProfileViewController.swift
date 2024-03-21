//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func btnLogout(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "VC") as! ViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
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
