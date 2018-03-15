//
//  SchoolSATInfo.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation

// represents info received from SATScore API
struct SchoolSATInfo: Codable {
    let dbn: String
    let testTakerCount: String?
    let readingAVG: String?
    let writingAVG: String?
    let mathAVG: String?
    let schoolName: String
    
    enum CodingKeys: String, CodingKey {
        case dbn
        case testTakerCount = "num_of_sat_test_takers"
        case readingAVG = "sat_critical_reading_avg_score"
        case writingAVG = "sat_writing_avg_score"
        case mathAVG = "sat_math_avg_score"
        case schoolName = "school_name"
    }
}
