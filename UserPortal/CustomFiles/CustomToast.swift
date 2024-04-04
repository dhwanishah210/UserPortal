//
//  CustomToast.swift
//  UserPortal
//
//  Created by Dhwani Shah on 27/03/24.
//
import UIKit

class CustomToast {
    
    static func show(message: String, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            let toastView = UIView()
            toastView.backgroundColor = UIColor(white: 0, alpha: 0.7)
            toastView.layer.cornerRadius = 10
            toastView.clipsToBounds = true
            toastView.translatesAutoresizingMaskIntoConstraints = false
            
            let toastLabel = UILabel()
            toastLabel.textColor = .white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 16)
            toastLabel.text = message
            toastLabel.numberOfLines = 0
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            
            toastView.addSubview(toastLabel)
            window.addSubview(toastView)
            
            // Constraints
            toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            toastView.widthAnchor.constraint(lessThanOrEqualToConstant: window.frame.width - 40).isActive = true
            toastView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            
            toastLabel.centerXAnchor.constraint(equalTo: toastView.centerXAnchor).isActive = true
            toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 20).isActive = true
            toastLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -20).isActive = true
            toastLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 20).isActive = true
            toastLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -20).isActive = true
            
            // Animate in
            UIView.animate(withDuration: 0.3) {
                toastView.alpha = 1.0
            } completion: { _ in
                // Animate out after duration
                UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut) {
                    toastView.alpha = 0.0
                } completion: { _ in
                    toastView.removeFromSuperview()
                }
            }
        }
    }
}
