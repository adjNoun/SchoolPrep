//
//  FullInfoSchool.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import Foundation


// a combination of the SATScore and Directory models
// instances of this object are used to populate:
// detail view
// saved school view
// locally stored schools
struct FullInfoSchool: Codable {
    let dbn: String
    let schoolName: String
    let mathAVG: String
    let readingAVG: String
    let writingAVG: String
    let extracurricularActivities: [String]
    let apCourses: [String]
    let overview: String
    let totalStudents: String
    let testTakerCount: String?
    let location: String
    
    init(fromDirectoryInfo school: SchoolDirectoryInfo, andSATInfo scores: SchoolSATInfo) {
        self.dbn = school.dbn
        self.schoolName = school.schoolName
        self.mathAVG = scores.mathAVG ?? "N/A"
        self.readingAVG = scores.readingAVG ?? "N/A"
        self.writingAVG = scores.writingAVG ?? "N/A"
        let activities = school.extracurricularActivities?.components(separatedBy: ", ") ?? []
        self.extracurricularActivities = activities
        let apCourses = school.apCourses?.components(separatedBy: ", ") ?? []
        self.apCourses = apCourses
        self.overview = school.overview
        self.totalStudents = school.totalStudents
        self.testTakerCount = scores.testTakerCount
        self.location = school.location
    }
}
