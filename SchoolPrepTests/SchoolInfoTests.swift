//
//  SchoolDirectoryInfoTests.swift
//  SchoolPrepTests
//
//  Created by Diego Baca on 3/15/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import XCTest
@testable import SchoolPrep

class SchoolInfoTests: XCTestCase {
    
    var school: SchoolDirectoryInfo!
    var score: SchoolSATInfo!
    var combination: FullInfoSchool!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        school = SchoolDirectoryInfo(schoolName: "someNAme", dbn: "123h8u", extracurricularActivities: nil, apCourses: nil, overview: "this is a test summary", totalStudents: "1234", location: "test address")
        score = SchoolSATInfo(dbn: "123h8u", testTakerCount: nil, readingAVG: nil, writingAVG: nil, mathAVG: nil, schoolName: "someNAme")
        combination = FullInfoSchool(fromDirectoryInfo: school, andSATInfo: score)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        school = nil
        score = nil
        combination = nil
    }
    
    func testSchoolAndScoreCombinedProperly() {
        XCTAssertTrue(combination.schoolName == school.schoolName)
        XCTAssertTrue(combination.dbn == score.dbn)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
