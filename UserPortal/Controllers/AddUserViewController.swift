//
//  AddUserViewController.swift
//  UserPortal
//
//  Created by Dhwani Shah on 29/03/24.
//

import UIKit
import ACFloatingTextfield_Swift

class AddUserViewController: UIViewController {
    
    var validation = Validations()
    
    @IBOutlet weak var radioFemale: UIButton!
    @IBOutlet weak var radioMale: UIButton!
    
    var radio: String? = " male"
    
    @IBOutlet weak var txtName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    
    var email: Bool = false
    var phone: Bool = false
    var name: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.delegate = self
        txtEmail.delegate = self
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
            radio = sender.title(for: .normal)
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
    
    @IBAction func btnBack(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "DashboardVC") as! DashboardViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        if email,phone,name{
            //print("API Request")
            var genderInt: Int?
            
            if radio?.lowercased() == " male"{
                genderInt = 0
            }else if radio?.lowercased() == " female"{
                genderInt = 1
            }
            
            guard let name = txtName.text,
                  let gender = genderInt,
                  let mobile = txtPhoneNumber.text,
                  let email = txtEmail.text else {
                return
            }
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            //Body to add the user data to the API
            let parameters: [String: Any] = [
                "name": name,
                "gender": gender,
                "mobile": mobile,
                "email": email
            ]
            
            print(parameters)
            // Make a POST request to the API endpoint to add user data
            ApiHelper.addUser(parameters: parameters) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("User added successfully to the API: \(response)")
                        if let responseData = response.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                            // Access the 'data' field from the JSON dictionary
                            let msg = json["message"] as? String
                            
                            //let create  = json
                            
                            CustomToast.show(message: msg!)
                            
                            if let data = json["data"] as? Int {
                                print("Data from response: \(data)")
                                let context = appDelegate.persistentContainer.viewContext
                                print(data)
                                // Create a new DbData object and insert it into Core Data
                                let dbDataObject = DbData(context: context)
                                //DataManager.count+=1
                                dbDataObject.id = Int16(data)
                                dbDataObject.name = name
                                dbDataObject.gender = Int16(gender)
                                dbDataObject.mobile = mobile
                                dbDataObject.email = email
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                                let currentDate = Date()
                                dbDataObject.createdAt = dateFormatter.string(from: currentDate)
                                dbDataObject.updatedAt = dateFormatter.string(from: currentDate)
                                // Save changes to Core Data
                                do {
                                    try context.save()
                                    print("Data saved successfully")
                                    let vc = self.storyboard?.instantiateViewController(identifier: "DashboardVC") as! DashboardViewController
                                    vc.modalPresentationStyle = .custom
                                    vc.transitioningDelegate = self
                                    self.navigationController?.popViewController(animated: true)
                                } catch {
                                    print("Error saving data: \(error.localizedDescription)")
                                    CustomToast.show(message: error.localizedDescription)
                                }
                            } else {
                                print("Failed to extract data from response.")
                            }
                        } else {
                            print("Failed to parse JSON response.")
                        }
                    case .failure(let error):
                        print("Failed to add user to API: \(error)")
                    }
                }
            }
            
        }else{
            CustomToast.show(message: "All Fields are required")
        }
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddUserViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(isPresenting: false)
    }
}


extension AddUserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }
}
