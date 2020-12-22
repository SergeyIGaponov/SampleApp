//
//  LocationServerViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import SDWebImage
import NetworkExtension
import RxSwift
import RxCocoa

class LocationServerViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    private let locationServerViewModel = LocationServerViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
    
    private func subscribe(){
        locationServerViewModel.selectedIp.asObservable().subscribe(onNext: { (_) in
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        ServerList.shared.serverList.asObservable().subscribe(onNext: { [weak self] (listServer) in
            if listServer.count > 0{
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
}

extension LocationServerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationServerViewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.locationServerTableViewCell.getId) as! LocationServerTableViewCell
        let data = locationServerViewModel.cellForRowAt(indexPath: indexPath)
        cell.dataCell = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationServerViewModel.didSelectRowAt(indexPath: indexPath)
    }
}

extension LocationServerViewController: LocationServerDelegate{
    var locationServerViewModelType: LocationServerViewModelType {
        return locationServerViewModel
    }
}
