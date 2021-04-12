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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
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
            self.descLabel.text = "Temp Sample Text"
            if !info.types.isEmpty {
                self.typeLabel.text = info.types[0]
            } else {
                self.typeLabel.text = "NULL"
            }
            self.addressLabel.text = "Address: " + info.address
            /*var openString = info.open
             if (openString == "No hours available"){
                
            } else {
                openString = info.open ? "Open" : "Closed"
            }*/
            let openString = info.open ? "Open" : "Closed"
            let hoursString = NSMutableAttributedString(string: "Hours: " + openString,
                                                        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                     NSAttributedString.Key.foregroundColor: UIColor.black])
            hoursString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: NSRange(location:7,length:4))
            self.hoursLabel.attributedText = hoursString
            
            self.ratingLabel.text = "Rating: " + String(info.rating)
            self.websiteLabel.text = "Website: " + info.website
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
