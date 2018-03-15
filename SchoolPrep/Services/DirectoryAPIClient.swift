//
//  DirectoryAPIClient.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation

enum DirectoryError: Error {
    case badUrl(String)
    case decodingError(rawError: Error)
    case otherError(rawError: Error)
}

enum DirectoryResult {
    case success([SchoolDirectoryInfo])
    case failure(DirectoryError)
}

// class to interface with NYC OPENDATA Public School Directory API
class DirectoryAPIClient {
    private init(){}
    static let manager = DirectoryAPIClient()
    static let limitPerPage: Int = 40
    
    private var page: Int = 0
    public var outOfResults = false
    
    // pieces of url
    private let rootURL: String = "https://data.cityofnewyork.us/resource/97mf-9njv.json?"
    private let appToken: String = "&$$app_token=aoUpKWrv8Km38DVZMY64wEID7"
    private var limit: String {return "&$limit=\(DirectoryAPIClient.limitPerPage)"}
    private var offset: String {return "&$offset=\(page * DirectoryAPIClient.limitPerPage)"}
    private var query: String = ""
    private var boroughs: String {
        var boros = [String]()
        for boroRawVal in 0..<5 {
            guard let boro = Boro(rawValue: boroRawVal) else {
                continue
            }
            if FilterSettings.manager.getValue(forBoro: boro) {
                switch boro {
                case .manhattan:
                    boros.append("boro = 'M'")
                case .queens:
                    boros.append("boro = 'Q'")
                case .brooklyn:
                    boros.append("boro = 'K'")
                case .bronx:
                    boros.append("boro = 'X'")
                case .statenIsland:
                    boros.append("boro = 'R'")
                }
            }
        }
        var whereClause = "&$where= " + boros.joined(separator: " OR ")
        if boros.isEmpty {
            // in practice causes an empty list to load if no boros selected
            whereClause += "boro = ''"
        }
        return whereClause
    }
    private var order: String = "&$order=school_name ASC"
    private var endPoint: String {
        get {
            if let urlStr = (rootURL + appToken + limit + offset + "&$q=\(query)" + order + boroughs).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return urlStr
            }
            return "could not encode url"
        }
    }
    
    // resets page count and query to start paging new list of data
    private func queueNewSearch(query: String) {
        self.page = 0
        self.query = query
        self.outOfResults = false
    }
    
    
    // MARK: - public functions
    
    // takes a new query to change endpoint and returns first page of data
    public func getFirstPageOfSchools(searchingFor search: String,
                                      completion: @escaping (DirectoryResult) -> Void) {
        queueNewSearch(query: search)
        guard let url = URL(string: endPoint) else {
            completion(.failure(.badUrl(endPoint)))
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // prepare data to hand off to completion block
        let requestComplete: (NetworkResult) -> Void = { [unowned self] networkResult in
            switch networkResult {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let onlineSchools = try decoder.decode([SchoolDirectoryInfo].self, from: data)
                    if onlineSchools.isEmpty {
                        self.outOfResults = true
                    }
                    completion(.success(onlineSchools))
                } catch {
                    completion(.failure(.decodingError(rawError: error)))
                }
            case .failure(let error):
                completion(.failure(.otherError(rawError: error)))
            }
        }
        NetworkHelper.manager.performTask(with: urlRequest, completion: requestComplete)
    }
    
    // uses the previous query to and increments page number
    // to get the next page of data for the same query
    public func getNextPageOfSchools(completion: @escaping (DirectoryResult) -> Void) {
        page += 1
        guard let url = URL(string: endPoint) else {
            completion(.failure(.badUrl(endPoint)))
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // prepare data to hand off to completion block
        let requestComplete: (NetworkResult) -> Void = { [unowned self] networkResult in
            switch networkResult {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let onlineSchools = try decoder.decode([SchoolDirectoryInfo].self, from: data)
                    if onlineSchools.isEmpty {
                        self.outOfResults = true
                    }
                    completion(.success(onlineSchools))
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
