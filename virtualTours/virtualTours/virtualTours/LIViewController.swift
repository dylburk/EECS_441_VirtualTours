//
//  LIViewController.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/23/21.
//

import Foundation
import UIKit

class LIViewController: UIViewController {
    
    @IBOutlet weak var IDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setIDText(text: String) {
        DispatchQueue.main.async {
            print(text)
            self.IDLabel.text = text;
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
