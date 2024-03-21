//
//  Data.swift
//  FinalProject
//
//  Created by Dhwani Shah on 20/03/24.
//



import Foundation

class ApiHelper {
    static func fetchEmployeeData(completion: @escaping (Result<MobilityAPI, Error>) -> Void) {
        let urlString = "http://192.168.2.160:9001/api/user/getAllUsers"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
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
}
