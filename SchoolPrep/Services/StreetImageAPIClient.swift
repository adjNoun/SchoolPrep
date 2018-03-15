//
//  StreetImageAPIClient.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import UIKit

enum StreetImageResult {
    case success(UIImage)
    case failure(StreetImageError)
}

enum StreetImageError: Error {
    case noImage
    case badData
    case networkError(rawError: Error)
    case badUrl(String)
}

// class to interface with Google Street Image View API
//
// this class is how the app interfaces with stored images as well
// before it makes a network call it checks to see if images are stored locally already
class StreetImageAPIClient {
    private init(){}
    static let manager = StreetImageAPIClient()
    
    private let apiKey = "AIzaSyARPaGAS3g4oaHzIpdHDk6iCn2FFgp1nP8"
    // helper -- make url from Violation
    private func urlString(from location: String) -> String {
        let url = "https://maps.googleapis.com/maps/api/streetview?size=640x640&location=\(location)&key=\(self.apiKey)"
        return url
    }
    
    
    // MARK: public functions
    public func getStreetImage(for location: String, completion: @escaping (StreetImageResult) -> Void) {
        
        guard let urlStr = urlString(from: location).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlStr) else {
            completion(.failure(.badUrl(urlString(from: location))))
            return
        }
        
        // doesn't do network call if the image can be found locally
        if let image = ImageStorageService.manager.getImage(atURL: urlStr) {
            completion(.success(image))
        }
        
        let urlRequest = URLRequest(url: url)
        
        // attempt to get image from online
        NetworkHelper.manager.performTask(with: urlRequest) { (result) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(.noImage))
                }
            case .failure(let error):
                completion(.failure(.networkError(rawError: error)))
            }
        }
    }
    
    
    // these functions are called when a user wants to
    // save a reference to a school
    // manages stored images through the ImageStorageService class
    
    // adds image to storage
    // using location as local url
    public func save(image: UIImage, forLocation location: String) {
        guard let urlStr = urlString(from: location).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        ImageStorageService.manager.store(image: image, atURL: urlStr)
    }
    
    // removes image from storage stored at the location url
    public func removeImage(forLocation location: String) {
        guard let urlStr = urlString(from: location).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        ImageStorageService.manager.removeImage(atURL: urlStr)
    }
}
