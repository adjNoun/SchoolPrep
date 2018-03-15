//
//  SavedSchoolsService.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

// both storage classes, SavedSchoolsService and ImageStorageService
// should be refactored to take completion blocks
// to allow for asynchronous calling
// and custom error handling


import Foundation


// class to interface with schools saved to device
class SavedSchoolsService {
    private init(){}
    static let manager = SavedSchoolsService()
    
    private let highSchoolsFileName = "highSchools.plist"
    private var highSchools = [FullInfoSchool]()
    private var highSchoolsDictionary = [String: FullInfoSchool]()
    
    private func documentsDirectory() -> URL {
        // TODO: stop force unwrap?
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private func path(forFile file: String) -> URL {
        return documentsDirectory().appendingPathComponent(file)
    }
    
    private func loadSchools() {
        do {
            let decoder = PropertyListDecoder()
            let url = path(forFile: highSchoolsFileName)
            let data = try Data.init(contentsOf: url)
            highSchools = try decoder.decode([FullInfoSchool].self, from: data)
            highSchools.forEach{ (school) in
                highSchoolsDictionary[school.dbn] = school
            }
        } catch {
            print(error)
        }
    }
    private func saveSchools() {
        do {
            let encoder = PropertyListEncoder()
            let url = path(forFile: highSchoolsFileName)
            let data = try encoder.encode(highSchools)
            try data.write(to: url)
        } catch {
            print(error)
        }
    }
    
    // MARK: - interface
    public func configure() {
        loadSchools()
    }
    
    public func add(school: FullInfoSchool) {
        highSchools.append(school)
        highSchoolsDictionary[school.dbn] = school
        saveSchools()
    }
    public func add(schools: [FullInfoSchool]) {
        highSchools += schools
        schools.forEach{ (school) in
            highSchoolsDictionary[school.dbn] = school
        }
        saveSchools()
    }
    public func set(schools: [FullInfoSchool]) {
        highSchools = schools
        schools.forEach{ (school) in
            highSchoolsDictionary[school.dbn] = school
        }
        saveSchools()
    }
    public func remove(school: FullInfoSchool) {
        guard let index = highSchools.index(where: {$0.dbn == school.dbn}) else {
            return
        }
        highSchools.remove(at: index)
        highSchoolsDictionary[school.dbn] = nil
        saveSchools()
    }
    public func getSchools() -> [FullInfoSchool] {
        return highSchools
    }
    public func isSaved(_ school: FullInfoSchool) -> Bool {
        return highSchoolsDictionary[school.dbn] != nil
    }
}
