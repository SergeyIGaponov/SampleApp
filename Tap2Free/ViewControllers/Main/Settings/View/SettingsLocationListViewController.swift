//
//  SettingsLocationListViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import SDWebImage

class SettingsLocationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isSelect: ((Int)->())? = nil
    var settingsLocViewModel: SettingsLocationListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let isSelect = isSelect{
            isSelect(settingsLocViewModel.getIndexSelectServer().row)
        }
    }
    
    @IBAction func hide(_ sender: UIButton) {
        if let isSelect = isSelect{
            isSelect(settingsLocViewModel.getIndexSelectServer().row)
        }
    }
    
}

extension SettingsLocationListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsLocViewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.locationServerTableViewCell.getId) as! LocationServerTableViewCell
        cell.dataCell = settingsLocViewModel.cellForRowAt(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsLocViewModel.didSelectAt(indexPath: indexPath)
        self.tableView.reloadData()
        if let isSelect = isSelect{
            isSelect(settingsLocViewModel.getIndexSelectServer().row)
        }
    }
    
}
