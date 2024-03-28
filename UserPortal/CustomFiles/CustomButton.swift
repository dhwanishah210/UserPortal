//
//  CustomButton.swift
//  FinalProject
//
//  Created by Dhwani Shah on 19/03/24.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
            super.init(frame: frame)
            setupButton()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupButton()
        }
        
        // MARK: - Setup
        
        private func setupButton() {
            setTitleColor(.white, for: .normal)
            
           // backgroundColor = UIColor.init(named: "Linear-Green")
            layer.cornerRadius = 10 // Adjust corner radius as per your requirement
            titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) // Adjust padding as needed
        }

}
