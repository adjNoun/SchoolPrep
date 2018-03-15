//
//  SavedSchoolsTableViewController.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import UIKit

class SavedSchoolsViewController: UIViewController {
    
    @IBOutlet weak var savedSchoolsTableView: UITableView!
    
    private var savedSchools = [FullInfoSchool]()
    
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedSchools()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "SavedDetailSegue",
            let selectedIndex = savedSchoolsTableView.indexPathForSelectedRow?.row,
            let detailVC = segue.destination as? SchoolDetailsViewController else {
                return
        }
        let fullInfoSchool = savedSchools[selectedIndex]
        detailVC.fullInfoSchool = fullInfoSchool
    }
    
    // MARK: - helper functions
    private func setupTableView() {
        savedSchoolsTableView.dataSource = self
        savedSchoolsTableView.delegate = self
        savedSchoolsTableView.separatorStyle = .singleLine
        savedSchoolsTableView.separatorColor = .black
        savedSchoolsTableView.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    private func loadSavedSchools() {
        savedSchools = SavedSchoolsService.manager.getSchools()
        savedSchoolsTableView.reloadData()
    }
}


// MARK: - tableview methods
extension SavedSchoolsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedSchools.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolTableViewCell", for: indexPath) as? SchoolTableViewCell else {
            return UITableViewCell()
        }
        
        let school = savedSchools[indexPath.row]
        cell.schoolName.text = school.schoolName
        cell.schoolDBN.text = school.dbn
        
        return cell
    }
}
