//
//  LIViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/23/21.
//

import Foundation
import UIKit

class LIViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    
    var id : String = ""
    
    let landmarkInfoLoader = LandmarkInfoLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if id != "" {
            landmarkInfoLoader.loadLandmark(id: id) { info, error in
                self.populateView(landmarkInfo: info, error: error)
            }
        }
        
    }
    
    func setID(id: String) {
        self.id = id
    }
    
    func populateView(landmarkInfo : LandmarkInfo?, error : NSError?) {
        if (error != nil) {
            print("Something went wrong getting landmarks")
            return
        }
        
        guard let info = landmarkInfo else {
            print("Something went wrong getting landmarks")
            return
        }
        
        DispatchQueue.main.async {
            self.titleLabel.text = info.name
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
