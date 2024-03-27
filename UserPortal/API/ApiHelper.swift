//
//  Data.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//

import Foundation

class ApiHelper {
    
    //READ
    static func fetchUserData(completion: @escaping (Result<MobilityAPI, Error>) -> Void) {
        let urlString = "http://192.168.2.160:901/api/user/getAllUsers"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let newsFeed = try decoder.decode(MobilityAPI.self, from: data)
                completion(.success(newsFeed))
            } catch {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
    
    
    //CREATE
    static func addUser(parameters: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.2.160:9001/api/user/addUser") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTP Error", code: -1, userInfo: nil)))
                return
            }
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                completion(.success(responseBody))
                print("OK")
            } else {
                completion(.failure(NSError(domain: "No Data Received", code: -1, userInfo: nil)))
            }
        }
        
        task.resume()
    }
    
    
    //UPDATE
    static func updateUser(parameters: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.2.160:9001/api/user/updateUser") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // or "PATCH" depending on the API requirements
        
        // Set request body with parameters
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTP Error", code: -1, userInfo: nil)))
                return
            }
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                completion(.success(responseBody))
            } else {
                completion(.failure(NSError(domain: "No Data Received", code: -1, userInfo: nil)))
            }
        }
        
        task.resume()
    }
    
    
    //DELETE
    static func deleteUser(parameters: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
 
        guard let url = URL(string: "http://192.168.2.160:9001/api/user/deleteUser") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            // Convert parameters to JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTP Error", code: -1, userInfo: nil)))
                return
            }
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                completion(.success(responseBody))
                print("DELETE SUCCESS")
            } else {
                completion(.failure(NSError(domain: "No Data Received", code: -1, userInfo: nil)))
            }
        }
        
        task.resume()
    }
    
}
