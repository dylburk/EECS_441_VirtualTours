//
//  LIViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/23/21.
//

import Foundation
import UIKit

func formatTypeString(types: [String]) -> String {
    if types.isEmpty {
        return "NULL"
    }
    
    var type = types[0]
    
    type = type.replacingOccurrences(of: "_", with: " ")
    return type.capitalized
}

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
            self.descLabel.text = info.description
            self.typeLabel.text = formatTypeString(types: info.types)
            self.addressLabel.text = "Address: " + info.address
            
            let openString = info.open ? "Open" : "Closed"
            let hoursString = NSMutableAttributedString(string: "Hours: " + openString,
                                                        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                     NSAttributedString.Key.foregroundColor: UIColor.black])
            if info.open {
                hoursString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: NSRange(location:7,length:4))
            } else {
                hoursString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: NSRange(location:7,length:6))
            }
            
            self.hoursLabel.attributedText = hoursString
            
            self.ratingLabel.text = "Rating: " + String(info.rating)
            self.websiteLabel.text = "Website: " + info.website
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
