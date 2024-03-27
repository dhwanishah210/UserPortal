//
//  LoginViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 19/03/24.
//

import UIKit
import ACFloatingTextfield_Swift
class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    
    var email: Bool = false
    var pass: Bool = false
    
    var validation = Validations()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func emailChanged(_ sender: ACFloatingTextfield) {
        email = validation.emailValidation(txtEmail)
    }
    
    @IBAction func passwordChanged(_ sender: ACFloatingTextfield) {
        pass = validation.passwordValidation(txtPassword)
    }
    
    
    @IBAction func btnLogin(_ sender: CustomButton) {
        if email,pass{
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarViewController
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSignup(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignupVC") as! SignupViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: false)
    }
}
