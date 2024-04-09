//
//  Data.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import Foundation

struct Data: Codable {
    var id: Int?
    var name: String?
    var gender: Int?
    var email: String?
    var mobile: String?
    var createdAt: String?
    var updatedAt: String?
}

struct MobilityAPI: Codable {
    var status: Int = 0
    var data:[Data]?
    var message: String = ""
}
