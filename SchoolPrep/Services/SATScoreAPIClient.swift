//
//  SATScoreAPIClient.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation

enum SATScoreError: Error {
    case badUrl(String)
    case decodingError(rawError: Error)
    case otherError(rawError: Error)
}


enum SATScoreResult {
    case success([SchoolSATInfo])
    case failure(SATScoreError)
}

// class to interface with NYC OPENDATA SAT Scores API
class SATScoreAPIClient {
    private init(){}
    static let manager = SATScoreAPIClient()
    
    // pieces of url
    private let rootURL: String = "https://data.cityofnewyork.us/resource/734v-jeq5.json?"
    private let appToken: String = "&$$app_token=aoUpKWrv8Km38DVZMY64wEID7"
    private var endPoint: String {
        if let urlStr = (rootURL + appToken).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return urlStr
        }
        return "couldn't encode endPoint"
    }
    
    // MARK: - public functions
    public func getAllSATScores(completion: @escaping (SATScoreResult) -> Void) {
        guard let url = URL(string: endPoint) else {
            completion(.failure(.badUrl(endPoint)))
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // prepare data to hand off to completion block
        let requestComplete: (NetworkResult) -> Void  = {networkResult in
            switch networkResult {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let onlineScores = try decoder.decode([SchoolSATInfo].self, from: data)
                    completion(.success(onlineScores))
                } catch {
                    completion(.failure(.decodingError(rawError: error)))
                }
            case .failure(let error):
                completion(.failure(.otherError(rawError: error)))
            }
        }
        
        NetworkHelper.manager.performTask(with: urlRequest, completion: requestComplete)
    }
}
