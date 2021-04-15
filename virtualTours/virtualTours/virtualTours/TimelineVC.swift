//
//  TimelineVC.swift
//  virtualTours
//
//  Created by Ved Ameresh on 4/15/21.
//

import Foundation
import UIKit
import CoreLocation

class TimelineVC: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var landmarks: [Landmark]? = nil
    let landmarkInfoLoader = LandmarkInfoLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Timeline View landmarks: ")
        print(self.landmarks!)
        
        
        for landmark in landmarks! {
            // add row to table view
        }
            
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
