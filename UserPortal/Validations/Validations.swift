//
//  Validations.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import UIKit
import ACFloatingTextfield_Swift

class Validations{
    
    var pass: String = ""
    
    //EMAIL
    func emailValidation(_ sender: ACFloatingTextfield) -> Bool {
        if let email = sender.text
        {
            if email.isEmpty{
                sender.placeholder = "Email"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return false
            }
            else if let errorMessage = invalidEmail(email){
                sender.placeholder = errorMessage
                sender.selectedLineColor = UIColor.red
                sender.selectedPlaceHolderColor = UIColor.red
                return false
            }else{
                sender.placeholder = "Email"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return true
            }
        }
        return false
    }
    
    func invalidEmail(_ value: String) -> String?
    {
        let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        if !predicate.evaluate(with: value)
        {
            return "Invalid Email Address"
        }
        
        return nil
    }
    
    //PASSWORD
    func passwordValidation(_ sender: ACFloatingTextfield) -> Bool{
        pass = sender.text!
        if let password = sender.text
        {
            if password.isEmpty{
                sender.placeholder = "Password"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return false
            }
            else if let errorMessage = invalidPassword(password){
                sender.placeholder = errorMessage
                sender.selectedLineColor = UIColor.red
                sender.selectedPlaceHolderColor = UIColor.red
                return false
            }else{
                sender.placeholder = "Password"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return true
            }
        }
        return false
    }
    
    func invalidPassword(_ value: String) -> String?
    {
        if value.count < 8
        {
            return "Password must be at least 8 characters"
        }
        if containsDigit(value)
        {
            return "Password must contain at least 1 digit"
        }
        if containsLowerCase(value)
        {
            return "Password must contain at least 1 lowercase character"
        }
        if containsUpperCase(value)
        {
            return "Password must contain at least 1 uppercase character"
        }
        return nil
    }
    
    func containsDigit(_ value: String) -> Bool
    {
        let reqularExpression = ".*[0-9]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        return !predicate.evaluate(with: value)
    }
    
    func containsLowerCase(_ value: String) -> Bool
    {
        let reqularExpression = ".*[a-z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        return !predicate.evaluate(with: value)
    }
    
    func containsUpperCase(_ value: String) -> Bool
    {
        let reqularExpression = ".*[A-Z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        return !predicate.evaluate(with: value)
    }
    
    func confirmPasswordValidation(_ sender: ACFloatingTextfield) -> Bool{
        if let password = sender.text
        {
            if password.isEmpty{
                sender.placeholder = "Password"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return false
            }
            else if password != pass{
                sender.placeholder = "Password does not match"
                sender.selectedLineColor = UIColor.red
                sender.selectedPlaceHolderColor = UIColor.red
                return false
            }else{
                sender.placeholder = "Password"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return true
            }
        }
        return false
    }
    
    //PHONE NUMBER
    func phoneValidation(_ sender: ACFloatingTextfield) -> Bool {
        if let phoneNumber = sender.text
        {
            if phoneNumber.isEmpty{
                sender.placeholder = "Phone Number"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return false
            }
            else if let errorMessage = invalidPhoneNumber(phoneNumber){
                sender.placeholder = errorMessage
                sender.selectedLineColor = UIColor.red
                sender.selectedPlaceHolderColor = UIColor.red
                return false
            }else{
                sender.placeholder = "Phone Number"
                sender.selectedLineColor = UIColor(named: "CustomBlue")!
                sender.selectedPlaceHolderColor = UIColor(named: "CustomBlue")!
                return true
            }
        }
        return false
    }
    
    func invalidPhoneNumber(_ value: String) -> String?
    {
        let set = CharacterSet(charactersIn: value)
        if !CharacterSet.decimalDigits.isSuperset(of: set)
        {
            return "Phone Number must contain only digits"
        }
        
        if value.count != 10
        {
            return "Phone Number must be 10 Digits in Length"
        }
        return nil
    }
    
}
