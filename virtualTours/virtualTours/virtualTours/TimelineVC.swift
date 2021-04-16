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
        //print(landmarks![indexPath.row].address)
        cell.twords?.text = landmarks![indexPath.row].title
        cell.twords?.textColor = .black
        
 
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
            // add row to table view
        }*/
            
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
