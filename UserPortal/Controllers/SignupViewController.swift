//
//  SignupViewController.swift
//  FinalProject
//
//  Created by Dhwani Shah on 19/03/24.
//

import UIKit
import ACFloatingTextfield_Swift

class SignupViewController: UIViewController {
    
    var validation = Validations()
    
    @IBOutlet weak var radioFemale: UIButton!
    @IBOutlet weak var radioMale: UIButton!
    
    @IBOutlet weak var txtName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtConfirmPassword: ACFloatingTextfield!
    
    var email: Bool = false
    var pass: Bool = false
    var phone: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnRadioTapped(_ sender: UIButton) {
        radioMale.setImage(UIImage(named: "RBUnchecked"), for: .normal)
        radioFemale.setImage(UIImage(named: "RBUnchecked"), for: .normal)
        
        if sender.currentImage == UIImage(named: "RBUnchecked"){
            sender.setImage(UIImage(named: "RBChecked"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "RBUnchecked"), for: .normal)
        }
    }
    
    @IBAction func emailChanged(_ sender: ACFloatingTextfield) {
        email = validation.emailValidation(txtEmail)
    }
    
    @IBAction func phoneChanged(_ sender: ACFloatingTextfield) {
        phone = validation.phoneValidation(txtPhoneNumber)
    }
    
    @IBAction func passwordChanged(_ sender: ACFloatingTextfield) {
        pass = validation.passwordValidation(txtPassword)
    }
    
    @IBAction func confirmPassword(_ sender: ACFloatingTextfield) {
    }
    
    @IBAction func btnSignup(_ sender: CustomButton) {
        if email,pass,phone {
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarViewController
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginViewController 
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SignupViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: false)
    }
}
