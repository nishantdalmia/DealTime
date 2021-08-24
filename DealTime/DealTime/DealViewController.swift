//
//  DealViewController.swift
//  DealTime
//
//  Created by Nishant Dalmia on 12/03/21.
//

import UIKit
import SQLite

class DealViewController: UIViewController {
    
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var providerLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var directionsLbl: UILabel!
    
    var category = String()
    var provider = String()
    var discount = String()
    var directions = String()
    var affiliation = String()
    var discount_id = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLbl.text = category
        providerLbl.text = provider
        discountLbl.text = discount
        directionsLbl.text = directions
    }
    
    @IBAction func add_to_favourites(_ sender: Any) {
        let path = Bundle.main.path(forResource: "database", ofType: "sqlite3")!

        do {
            let db = try Connection(path, readonly: false)
            let executionStatement = "UPDATE " + affiliation + " SET FAVORITES = TRUE WHERE DISCOUNT_ID = " + String(discount_id)
            do {
                try db.execute(executionStatement)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
}

