//
//  ApiAccess.swift
//  CustomNavigationBar
//
//  Created by Jason Chen on 2019/9/9.
//  Copyright © 2019 Jason Chen. All rights reserved.
//

import Foundation

//
// MARK: - Api Access
//

/// Runs query data task, and stores results in array of Plants
class ApiAccess {
    //
    // MARK: - Constants
    //
    let defaultSession = URLSession(configuration: .default)
    let apiBaseUrl: String = "https://data.taipei/opendata/datalist/apiAccess"
    
    //
    // MARK: - Variables And Properties
    //
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var plants: Plants?
    
    //
    // MARK: - Type Alias
    //
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = (Plants?, String) -> Void

    //
    // MARK: - Internal Methods
    //
    func getSearchResults(countLimitPerPage: Int, offset: Int, completion: @escaping QueryResult) {
        // 1
        dataTask?.cancel()
        
        // 2
        if var urlComponents = URLComponents(string: apiBaseUrl) {
            urlComponents.query = "scope=resourceAquire&rid=f18de02f-b6c9-47c0-8cda-50efad621c14&limit=\(countLimitPerPage)&offset=\(offset)"
            
            // 3
            guard let url = urlComponents.url else {
                return
            }
            
            // 4
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                // 5
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print(response)
                    self?.updateSearchResults(data)
                    
                    // 6
                    DispatchQueue.main.async {
                        completion(self?.plants, self?.errorMessage ?? "")
                    }
                }
            }
            
            // 7
            dataTask?.resume()
        }
    }
    
    //
    // MARK: - Private Methods
    //
    private func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        var newPlants: [Plant] = []
        for plant in plants?.results ?? [] {
            // Copy the privous records from old arry to new array
            newPlants.append(Plant(F_Name_Ch: plant.F_Name_Ch, F_Location: plant.F_Location ?? "", F_Feature: plant.F_Feature ?? "", F_Pic01_URL: plant.F_Pic01_URL ?? ""))
        }
        // Remove all records from old array
        plants?.results.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let result = response!["result"] as? JSONDictionary else {
            errorMessage += "Dictionary does not contain result key\n"
            return
        }
        
        var varLimit: Int = 0
        var varOffset: Int = 0
        var varCount: Int = 0
        var varSort: String = ""
        var varPlants: [Plant] = []
        if let limit = result["limit"] as? Int,
            let offset = result["offset"] as? Int,
            let count = result["count"] as? Int,
            let sort = result["sort"] as? String,
            let plants = result["results"] as? [JSONDictionary] {
            varLimit = limit
            varOffset = offset
            varCount = count
            varSort = sort
            for plantsDictionary in plants {
                let F_Name_Ch = plantsDictionary["F_Name_Ch"] as? String ?? ""
                let F_Location = plantsDictionary["F_Location"] as? String ?? ""
                let F_Feature = plantsDictionary["F_Feature"] as? String ?? ""
                let F_Pic01_URL = plantsDictionary["F_Pic01_URL"] as? String ?? ""
                // Append new records
                newPlants.append(Plant(F_Name_Ch: F_Name_Ch, F_Location: F_Location, F_Feature: F_Feature, F_Pic01_URL: F_Pic01_URL))
            }
            varPlants = newPlants
        } else {
            errorMessage += "Problem parsing resultDictionary\n"
        }
    
        plants = Plants(limit: varLimit, offset: varOffset, count: varCount, sort: varSort, results: varPlants)
    }
}
