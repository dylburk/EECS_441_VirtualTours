//
//  MenuController.swift
//  virtualTours
//
//  Created by Nikhil Tangella on 4/10/21.
//

import Foundation
import UIKit

protocol MenuControllerDelegate {
    func didSelectMenuItem(named: String)
}

class MenuController: UITableViewController {


    public var delegate: MenuControllerDelegate?
    private let menuItems: [String]
    
    init(with menuItems: [String]) {
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.words?.text = menuItems[indexPath.row]
        cell.words?.textColor = .black
        if (cell.words.text == "Home") {
            cell.picture?.image =  UIImage(systemName: "camera.fill")
        }
        else if (cell.words.text == "Timeline") {
            cell.picture?.image =  UIImage(systemName: "clock.arrow.circlepath")
        }
        else if (cell.words.text == "Map") {
            cell.picture?.image =  UIImage(systemName: "mappin.and.ellipse")
        }
        else if (cell.words.text == "Settings") {
            cell.picture?.image =  UIImage(systemName: "gearshape.fill")
        }
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //relay the selection
        let selectedItem = menuItems[indexPath.row]
        delegate?.didSelectMenuItem(named: selectedItem)
    }
    
}
