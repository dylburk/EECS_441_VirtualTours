//
//  ViewController.swift
//  virtualTours
//
//  Created by Dylan Burkett on 3/5/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let store = NearbyStore()
        store.getNearby(refresh: {}, completion: {})
    }


}

