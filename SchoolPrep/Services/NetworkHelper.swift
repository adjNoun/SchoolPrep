//
//  NetworkHelper.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation

import SystemConfiguration

enum NetworkError: Error {
    case noData
    case otherError(rawError: Error)
}

enum NetworkResult {
    case success(Data)
    case failure(NetworkError)
}

class NetworkHelper {
    private init(){}
    static let manager = NetworkHelper()
    
    private let session = URLSession(configuration: .default)
    
    // general purpose function to check internet connection
    public func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // main helper function to carry out any networking requests
    // completion block for asynchronous calls
    public func performTask(with url: URLRequest,
                            completion: @escaping (NetworkResult) -> Void) {
        self.session.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                if let response = response {
                    print(response.url!.absoluteString)
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                if let error = error {
                    completion(.failure(.otherError(rawError: error)))
                } else {
                    completion(.success(data))
                }
            }
            }.resume()
    }
    
}
