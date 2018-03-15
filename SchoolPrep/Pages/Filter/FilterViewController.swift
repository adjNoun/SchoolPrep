//
//  FilterViewController.swift
//  SchoolPrep
//
//  Created by Diego Baca on 3/12/18.
//  Copyright © 2018 Diego Baca. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet var switches: [UISwitch]!
    
    // reflect switch changes in FilterSettings class
    @IBAction func filterSwitched(_ sender: UISwitch) {
        guard let boro = Boro(rawValue: sender.tag) else {
            return
        }
        FilterSettings.manager.setFilter(forBoro: boro, to: sender.isOn)
        
    }
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set switches to reflect status of FilterSettings class
        for filterSwitch in switches {
            guard let boro = Boro(rawValue: filterSwitch.tag) else {
                continue
            }
            let value = FilterSettings.manager.getValue(forBoro: boro)
            filterSwitch.setOn(value, animated: false)
        }
        
    }
}
