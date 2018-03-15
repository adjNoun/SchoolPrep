//
//  FilterSettings.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation

enum Boro: Int {
    case manhattan
    case queens
    case brooklyn
    case bronx
    case statenIsland
}

// global class used by the filter view and DirectoryAPIClient
// used in creating url endpoint to filter by boro
// light enough to store in userDefaults for persistence
class FilterSettings {
    private init() {
        self.manhattan = UserDefaults.standard.object(forKey: "Manhattan") as? Bool ?? true
        self.queens = UserDefaults.standard.object(forKey: "Queens") as? Bool ?? true
        self.brooklyn = UserDefaults.standard.object(forKey: "Brooklyn") as? Bool ?? true
        self.bronx = UserDefaults.standard.object(forKey: "Bronx") as? Bool ?? true
        self.statenIsland = UserDefaults.standard.object(forKey: "StatenIsland") as? Bool ?? true
    }
    
    static let manager = FilterSettings()
    private var manhattan: Bool
    private var queens: Bool
    private var brooklyn: Bool
    private var bronx: Bool
    private var statenIsland: Bool
    public var filtersChanged: Bool = false
    
    
    public func setFilter(forBoro boro: Boro, to value: Bool) {
        filtersChanged = true
        switch boro {
        case .manhattan:
            manhattan = value
            UserDefaults.standard.set(value, forKey: "Manhattan")
        case .queens:
            queens = value
            UserDefaults.standard.set(value, forKey: "Queens")
        case .brooklyn:
            brooklyn = value
            UserDefaults.standard.set(value, forKey: "Brooklyn")
        case .bronx:
            bronx = value
            UserDefaults.standard.set(value, forKey: "Bronx")
        case .statenIsland:
            statenIsland = value
            UserDefaults.standard.set(value, forKey: "StatenIsland")
        }
    }
    public func getValue(forBoro boro: Boro) -> Bool {
        filtersChanged = false
        switch boro {
        case .manhattan:
            return manhattan
        case .queens:
            return queens
        case .brooklyn:
            return brooklyn
        case .bronx:
            return bronx
        case .statenIsland:
            return statenIsland
        }
    }
    
}
