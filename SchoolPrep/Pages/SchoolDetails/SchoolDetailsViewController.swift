//
//  SchoolDetailsViewController.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import UIKit

class SchoolDetailsViewController: UIViewController {
    
    
    
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var schoolAddress: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var mathScore: UILabel!
    @IBOutlet weak var readingScore: UILabel!
    @IBOutlet weak var writingScore: UILabel!
    @IBOutlet weak var testCount: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var streetImageView: UIImageView!
    @IBOutlet weak var loadingImageView: UIView!
    @IBOutlet weak var loadingImageIndicator: UIActivityIndicatorView!
    
    public var fullInfoSchool: FullInfoSchool?
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let school = fullInfoSchool else {
            return
        }
        // remove if saved
        if SavedSchoolsService.manager.isSaved(school) {
            SavedSchoolsService.manager.remove(school: school)
            StreetImageAPIClient.manager.removeImage(forLocation: school.location)
            saveButton.title = "Save"
        } else {
            
        // save if not currently saved
            SavedSchoolsService.manager.add(school: school)
            StreetImageAPIClient.manager.save(image: streetImageView.image!, forLocation: school.location)
            saveButton.title = "Remove"
        }
        
        
    }
    
    // MARK: - view controller life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        streetImageView.image = #imageLiteral(resourceName: "placeholder")
        
        // change "save" button based on
        // if the school is already saved or not
        if let fullInfoSchool = fullInfoSchool, SavedSchoolsService.manager.isSaved(fullInfoSchool) {
            saveButton.title = "Remove"
        }
        
        loadStreetView()
        setupPage()
    }
    
    // MARK: - helper functions
    private func loadStreetView() {
        guard let fullInfoSchool = fullInfoSchool else {
            streetImageView.image = #imageLiteral(resourceName: "placeholder")
            return
        }
        toggleLoadingIndicator()
        StreetImageAPIClient.manager.getStreetImage(for: fullInfoSchool.location) {[unowned self] (result) in
            switch result {
            case .success(let onlineImage):
                self.streetImageView.image = onlineImage
            case .failure(_):
                self.streetImageView.image = #imageLiteral(resourceName: "placeholder")
            }
            self.toggleLoadingIndicator()
        }
    }
    
    private func setupPage() {
        // we should always have school info when
        // displaying details
        // but guard just in case, for now
        guard let school = fullInfoSchool else {
            return
        }
        
        schoolName.text = school.schoolName
        schoolAddress.text = removeLatLonFrom(address: school.location)
        
        // if we have actual info then diplay scores
        if let math = Int(school.mathAVG),
            let reading = Int(school.readingAVG),
            let writing = Int(school.writingAVG) {
            let total = math + reading + writing
            totalScore.text = "\(total)"
            mathScore.text = "\(math)"
            readingScore.text = "\(reading)"
            writingScore.text = "\(writing)"
        } else {
            // if data came back empty for this school then show N/A
            totalScore.text = "N/A"
            mathScore.text = "N/A"
            readingScore.text = "N/A"
            writingScore.text = "N/A"
            
        }
        totalScore.text?.append(" / 2400")
        mathScore.text?.append(" / 800")
        readingScore.text?.append(" / 800")
        writingScore.text?.append(" / 800")
        
        testCount.text = school.testTakerCount ?? "N/A"
    }
    
    // helps with gettings lat and long numbers out of
    // address string to display normal address
    private func removeLatLonFrom(address: String) -> String{
        if let parenthesisIndex = address.index(of: "(") {
            let latLonRange = parenthesisIndex..<address.endIndex
            var address = address
            address.removeSubrange(latLonRange)
            return address
        }
        return address
    }
    
    
    // show loading indicator while
    // street image is being fetched
    private func toggleLoadingIndicator() {
        if loadingImageView.isHidden {
            loadingImageView.isHidden = false
            loadingImageIndicator.startAnimating()
        } else {
            loadingImageView.isHidden = true
            loadingImageIndicator.stopAnimating()
        }
    }
}
