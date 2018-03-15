//
//  SchoolDirectoryInfo.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation


// represents info received from SchoolDirectory API
// some properties not yet used
struct SchoolDirectoryInfo: Codable {
    let schoolName: String
    let dbn: String
    let extracurricularActivities: String?
    let apCourses: String?
    let overview: String
    let totalStudents: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case schoolName = "school_name"
        case dbn
        case extracurricularActivities = "extracurricular_activities"
        case apCourses = "advancedplacement_courses"
        case overview = "overview_paragraph"
        case totalStudents = "total_students"
        case location
    }
}
