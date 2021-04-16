//
//  TimelineVC.swift
//  virtualTours
//
//  Created by Ved Ameresh on 4/15/21.
//

import Foundation
import UIKit
import CoreLocation

class TimelineVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineViewCell", for: indexPath) as! TimelineViewCell
        cell.backgroundColor = .white
        let id = landmarks![indexPath.row].id
        
        let semaphore = DispatchSemaphore(value: 0)
        
        landmarkInfoLoader.loadLandmark(id: id) { info, error in
            if (error != nil){
                print("ERROR")
            }
            semaphore.signal()
            DispatchQueue.main.async {
                cell.twords?.text = info!.name
                cell.twords?.textColor = .black
                cell.twords?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                cell.address?.text = info!.address
                cell.address?.textColor = .black
                cell.srating?.text = "Rating:"
                cell.srating?.textColor = .black
                cell.nrating?.text = String(info!.rating)
                cell.nrating?.textColor = .black
                print(info!)
            }
        }
        semaphore.wait()
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks!.count
    }

    
    
    @IBOutlet weak var tableView: UITableView!
    
    var landmarks: [Landmark]? = nil
    let landmarkInfoLoader = LandmarkInfoLoader()
    
    let cellReuseIdentifier = "TimelineViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.landmarks!)
        tableView.backgroundColor = UIColor.white
        tableView.rowHeight = 150.0
        tableView.delegate = self
        tableView.dataSource = self
        let header = UIView()
        header.frame.size.height = 60.0
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "TimelineViewCell", bundle: nil), forCellReuseIdentifier: "TimelineViewCell")
        
        /*
        for landmark in landmarks! {
        }*/
            
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
