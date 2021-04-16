//
//  TimelineViewCell.swift
//  virtualTours
//
//  Created by Nikhil Tangella on 4/16/21.
//

import Foundation
import UIKit

class TimelineViewCell: UITableViewCell {
    
    @IBOutlet weak var nrating: UILabel!
    
    @IBOutlet weak var srating: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var twords: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
