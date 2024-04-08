//
//  AddUserViewController.swift
//  UserPortal
//
//  Created by Dhwani Shah on 29/03/24.
//

import UIKit
import ACFloatingTextfield_Swift
import CoreData

class AddUserViewController: UIViewController {
    
    var validation = Validations()
    var editMode = false
    var dataToEdit: Data?
    var email: Bool = false
    var phone: Bool = false
    var name: Bool = true
    var radio: String? = " male"
    var genderInt: Int?
    
    @IBOutlet weak var radioFemale: UIButton!
    @IBOutlet weak var radioMale: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.delegate = self
        txtEmail.delegate = self
        txtPhoneNumber.keyboardType = .numberPad
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        if editMode, let data = dataToEdit {
            // Populate fields with data for editing
            lblTitle.text = "EDIT USER"
            txtName.text = data.name
            txtEmail.text = data.email
            txtPhoneNumber.text = data.mobile
            if data.gender == 1 {
                btnRadioTapped(radioFemale)
            } else {
                btnRadioTapped(radioMale)
            }
        }
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
        guard let name1 = txtName.text, !name1.isEmpty else {
            CustomToast.show(message: "Name is required")
            return
        }
        
        guard let email1 = txtEmail.text, !email1.isEmpty, validation.emailValidation(txtEmail) else {
            CustomToast.show(message: "Invalid email")
            return
        }
        
        guard let mobile1 = txtPhoneNumber.text, !mobile1.isEmpty, validation.phoneValidation(txtPhoneNumber) else {
            CustomToast.show(message: "Invalid phone number")
            return
        }
        
        if radio?.lowercased() == " male"{
            genderInt = 0
        }else if radio?.lowercased() == " female"{
            genderInt = 1
        }
        
        if editMode {
            self.updateData(id: dataToEdit?.id ?? 0, newName: name1, newEmail: email1, newGender: Int16(genderInt ?? 0), newMobile: mobile1)
        }  else {
            if email,phone,name{
                guard let name = txtName.text,
                      let mobile = txtPhoneNumber.text,
                      let email = txtEmail.text else {
                    return
                }
                addUser(name: name, gender: genderInt ?? 0, mobile: mobile, email: email)
            }else{
                CustomToast.show(message: "All Fields are required")
            }
        }
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateData(id: Int, newName: String, newEmail: String, newGender: Int16, newMobile: String) {
        
        let parameters: [String: Any] = [
            "id": id,
            "name": newName,
            "gender": newGender,
            "email": newEmail,
            "mobile": newMobile
        ]
        
        ApiHelper.updateUser(parameters: parameters) { result in
            switch result {
            case .success(let response):
                print("User data updated successfully: \(response)")
                
                // Access the managed object context from the app delegate
                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    let context = appDelegate.persistentContainer.viewContext
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // Format for full date and time
                    let dateTimeString = dateFormatter.string(from: currentDate)
                    
                    // Fetch the corresponding DbData object from the database using its unique identifier (ID)
                    let fetchRequest: NSFetchRequest<DbData> = DbData.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
                    print(id)
                    do {
                        if let dbDataObject = try context.fetch(fetchRequest).first {
                            // Update the attributes of the DbData object with the new values
                            dbDataObject.name = newName
                            dbDataObject.email = newEmail
                            dbDataObject.updatedAt = dateTimeString
                            
                            // Save the changes to the database
                            try context.save()
                            let vc = self.storyboard?.instantiateViewController(identifier: "DashboardVC") as! DashboardViewController
                            vc.modalPresentationStyle = .custom
                            vc.transitioningDelegate = self
                            self.navigationController?.popViewController(animated: true)
                            DashboardViewController().fetchUserData()
                        } else {
                            print("Data not found in database.")
                        }
                    } catch {
                        print("Error updating data: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Failed to update user data: \(error)")
                CustomToast.show(message: error.localizedDescription)
            }
        }
    }
    
    func addUser(name: String, gender: Int, mobile: String, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let parameters: [String: Any] = [
            "name": name,
            "gender": gender,
            "mobile": mobile,
            "email": email
        ]
        
        ApiHelper.addUser(parameters: parameters) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let responseData = response.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        let msg = json["message"] as? String
                        
                        CustomToast.show(message: msg ?? "User added successfully to the API")
                        
                        if let data = json["data"] as? Int {
                            let context = appDelegate.persistentContainer.viewContext
                            let dbDataObject = DbData(context: context)
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
