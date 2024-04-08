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
    var email: Bool = false
    var phone: Bool = false
    var pass: Bool = false
    var confirmPass: Bool = false
    
    @IBOutlet weak var btnProfilePhoto: UIButton!
    @IBOutlet weak var btnSignup: CustomButton!
    @IBOutlet weak var radioFemale: UIButton!
    @IBOutlet weak var radioMale: UIButton!
    @IBOutlet weak var txtName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtConfirmPassword: ACFloatingTextfield!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.delegate = self
        txtPassword.delegate = self
        txtEmail.delegate = self
        txtConfirmPassword.delegate = self
        txtPhoneNumber.keyboardType = .numberPad
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Check if tap is outside the text field
        if !txtPhoneNumber.frame.contains(sender.location(in: view)) {
            txtPhoneNumber.resignFirstResponder() // Dismiss the keyboard
        }
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
        confirmPass = validation.confirmPasswordValidation(txtConfirmPassword)
    }
    
    @IBAction func btnSignup(_ sender: CustomButton) {
        if email,pass,phone {
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarViewController
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            CustomToast.show(message: "All Fields are required")
        }
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginViewController 
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPhoto(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Select from Gallery", style: .default) { _ in
            // Handle action for selecting from gallery
            self.selectFromGallery()
        }
        if let galleryImage = UIImage(named: "GalleryIcon") {
            galleryAction.setValue(galleryImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            // Handle action for taking a photo
            self.takePhoto()
        }
        if let cameraImage = UIImage(named: "CameraIcon") {
            takePhotoAction.setValue(cameraImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func selectFromGallery() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func takePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker,animated: true)
    }
    
}

extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        btnProfilePhoto.setImage(image, for: .normal)
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

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }
}

protocol ProfileImageDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
}
