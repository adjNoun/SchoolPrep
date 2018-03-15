//
//  ImageStorageService.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import UIKit

// class to interface with schools saved to device
class ImageStorageService {
    private init(){}
    static let manager = ImageStorageService()
    
    private var cachedImages = [String: UIImage]()
    
    private func documentsDirectory() -> URL {
        // TODO: stop force unwrap?
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private func path(forFile file: String) -> URL {
        return documentsDirectory().appendingPathComponent(file)
    }
    
    public func store(image: UIImage, atURL urlStr: String) {
        do {
            let data = UIImagePNGRepresentation(image)
            let url = path(forFile: urlStr)
            try data?.write(to: url)
            cachedImages[urlStr] = image
        } catch {
            print(error)
        }
    }
    public func removeImage(atURL urlStr: String) {
        let url = path(forFile: urlStr)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
    
    // on first access an image is retrieved from storage
    // an image is "cached" in the cachedImages property
    // future access retrieves image from cachedImages
    public func getImage(atURL urlStr: String) -> UIImage? {
        if let image = cachedImages[urlStr] {
            return image
        } else {
            do {
                let data = try Data(contentsOf: path(forFile: urlStr))
                if let image = UIImage(data: data) {
                    cachedImages[urlStr] = image
                    return image
                }
                return nil
            } catch {
                return nil
            }
        }
    }
    
    
    
    
}
