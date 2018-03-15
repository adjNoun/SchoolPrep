//
//  HighSchoolsTableViewController.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import UIKit

class MainListViewController: UIViewController {
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var schoolTableView: UITableView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var loadingDataView: UIView!
    @IBOutlet weak var loadingDataIndicator: UIActivityIndicatorView!
    
    
    
    private var schools = [SchoolDirectoryInfo]()
    private var scores = [SchoolSATInfo]()
    private var loadingNextPage = false
    
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupTableView()
        loadInitialData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // temporary fix for bug in ios 11
        // barbutton items stayed dim after already pressed
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        
        // reload data in list if filters changed
        if FilterSettings.manager.filtersChanged {
            toggleLoadingIndicator()
            let search = searchBar.text ?? ""
            DirectoryAPIClient.manager.getFirstPageOfSchools(searchingFor: search) { [unowned self] (result) in
                switch result {
                case .success(let onlineSchools):
                    self.schools = onlineSchools
                    self.schoolTableView.reloadData()
                case .failure(_):
                    self.showErrorAlert()
                }
                self.toggleLoadingIndicator()
            }
        }
    }
    
    // hand off school info to the detailVC when selecting a cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "OnlineDetailSegue",
            let selectedIndex = schoolTableView.indexPathForSelectedRow?.row,
            let detailVC = segue.destination as? SchoolDetailsViewController else {
                return
        }
        let school = schools[selectedIndex]
        // if school can't be matched with a score then create a "score" object
        let score = scores.first(where: {$0.dbn == school.dbn})
                    ?? SchoolSATInfo(dbn: school.dbn, testTakerCount: nil, readingAVG: nil, writingAVG: nil, mathAVG: nil, schoolName: school.schoolName)
        let fullInfoSchool = FullInfoSchool(fromDirectoryInfo: school, andSATInfo: score)
        detailVC.fullInfoSchool = fullInfoSchool
    }
    
    
    // MARK: - helper functions
    
    // display default list on first opening
    private func loadInitialData() {
        toggleLoadingIndicator()
        
        // get directory info, in small ranges to avoid long network wait times
        DirectoryAPIClient.manager.getFirstPageOfSchools(searchingFor: "") {[unowned self] (result) in
            switch result {
            case .success(let onlineSchools):
                self.schools = onlineSchools
                self.schoolTableView.reloadData()
            case .failure(_):
                self.showErrorAlert()
            }
        }
        // get all sat scores
        // data small enough to make one large call
        // have a loading indicator shown until this request has completed
        SATScoreAPIClient.manager.getAllSATScores {[unowned self] (result) in
            switch result {
            case .success(let onlineScores):
                self.scores = onlineScores
            case .failure(_):
                self.showErrorAlert()
            }
            self.toggleLoadingIndicator()
        }
    }
    private func setupTableView() {
        searchBar.delegate = self
        schoolTableView.dataSource = self
        schoolTableView.delegate = self
        schoolTableView.separatorStyle = .singleLine
        schoolTableView.separatorColor = .black
        schoolTableView.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func toggleLoadingIndicator() {
        if loadingDataView.isHidden {
            loadingDataView.isHidden = false
            loadingDataIndicator.startAnimating()
        } else {
            loadingDataView.isHidden = true
            loadingDataIndicator.stopAnimating()
        }
    }
    private func showErrorAlert() {
        let alert = UIAlertController(title: "OH NO", message: "Something went wrong", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension MainListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let search = searchBar.text else {
            return
        }
        
        let getNewList: (DirectoryResult) -> Void =
        { [unowned self] (dirResult) in
            switch dirResult {
            case .success(let onlineSchools):
                self.schools = onlineSchools
                self.schoolTableView.reloadData()
            case .failure(_):
                self.showErrorAlert()
            }
        }
        DirectoryAPIClient.manager.getFirstPageOfSchools(searchingFor: search, completion: getNewList)
        searchBar.resignFirstResponder()
    }
}


extension MainListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolTableViewCell", for: indexPath) as? SchoolTableViewCell else {
            return UITableViewCell()
        }
        let school = schools[indexPath.row]
        cell.schoolName.text = school.schoolName
        cell.schoolDBN.text = school.dbn
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowToLoadMoreDataFrom = schools.count - (DirectoryAPIClient.limitPerPage / 2)
        let loadNextPageOfSchools:(DirectoryResult) -> Void =
        { [unowned self] (result) in
            self.loadingNextPage = false
            switch result {
            case .success(let onlineSchools):
                self.schools += onlineSchools
                self.schoolTableView.reloadData()
            case .failure(_):
                self.showErrorAlert()
            }
        }
        if indexPath.row >= rowToLoadMoreDataFrom
            && !loadingNextPage
            && !DirectoryAPIClient.manager.outOfResults
            && NetworkHelper.manager.isInternetAvailable(){
            loadingNextPage = true
            DirectoryAPIClient.manager.getNextPageOfSchools(completion: loadNextPageOfSchools)
        }
    }
    
    
}
