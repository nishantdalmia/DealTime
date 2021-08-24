//
//  ViewController.swift
//  DealTime
//
//  Created by Nishant Dalmia on 07/03/21.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    @IBOutlet weak var discountTypeTxt: UITextField!
    @IBOutlet weak var affiliationTxt: UITextField!
        
    let discountType = ["Attractions & Theme Parks", "Automotive", "Cellular Phones & Accessories", "Clothing & Accessories",
                        "Computers & Electronics", "Dining & Entertainment", "Fitness Centers & Equipment", "Flowers & Gifts",
                        "Grocery", "Health & Beauty", "Home & Garden", "Miscellaneous", "Money & Investing", "Optical", "Pets & Supplies",
                        "Sports & Outdoors", "Storage & Moving", "Travel", "University of Michigan"]
    let affiliation = ["Faculty & Staff", "Students", "Others"]
    
    var discountPickerView = UIPickerView()
    var affiliationPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        discountPickerView.delegate = self
        discountPickerView.dataSource = self
        affiliationPickerView.delegate = self
        affiliationPickerView.dataSource = self
        
        discountTypeTxt.inputView = discountPickerView
        affiliationTxt.inputView = affiliationPickerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DealListViewController
        destination.deals.removeAll()
        
        if (segue.identifier == "showDealsSegue") {
            destination.category = discountTypeTxt.text!
        }
        else {
            destination.category = "Favorites"
        }
        
        let path = Bundle.main.path(forResource: "database", ofType: "sqlite3")!
        
        do {
            let db = try Connection(path, readonly: true)
            
            let map = ["Faculty & Staff": "FACULTY_STAFF",
                       "Students": "STUDENTS",
                       "Others": "OTHERS"]
            let provider = Expression<String?>("PROVIDER_NAME")
            let discount = Expression<String?>("DISCOUNT_NAME")
            let directions = Expression<String?>("DIRECTIONS")
            let discount_type = Expression<String?>("DISCOUNT_TYPE")
            let discount_id = Expression<Int?>("DISCOUNT_ID")
            let favorites = Expression<Bool?>("FAVORITES")
            
            if (segue.identifier == "showDealsSegue") {
                do {
                    let table = Table(map[affiliationTxt.text!]!)
                    let listings = try db.prepare(table)
                    for entry in listings {
                        if (entry[discount_type] == discountTypeTxt.text!) {
                            destination.deals.append(DealListViewController.Deal(provider: entry[provider]!, discount: entry[discount]!, directions: entry[directions]!,                                                                     affiliation: map[affiliationTxt.text!]!, discount_id: entry[discount_id]!))
                        }
                    }
                } catch {
                    print(error)
                }
            }
            else {
                do {
                    let fTable = Table("FACULTY_STAFF")
                    let sTable = Table("STUDENTS")
                    let oTable = Table("OTHERS")
                    
                    let flistings = try db.prepare(fTable)
                    for entry in flistings {
                        if (entry[favorites] == true)    {
                            destination.deals.append(DealListViewController.Deal(provider: entry[provider]!, discount: entry[discount]!, directions: entry[directions]!,                                                                     affiliation: "FACULTY_STAFF", discount_id: entry[discount_id]!))
                        }
                    }
                    let slistings = try db.prepare(sTable)
                    for entry in slistings {
                        if (entry[favorites] == true)    {
                            destination.deals.append(DealListViewController.Deal(provider: entry[provider]!, discount: entry[discount]!, directions: entry[directions]!,                                                                     affiliation: "STUDENTS", discount_id: entry[discount_id]!))
                        }
                    }
                    let olistings = try db.prepare(oTable)
                    for entry in olistings {
                        if (entry[favorites] == true)    {
                            destination.deals.append(DealListViewController.Deal(provider: entry[provider]!, discount: entry[discount]!, directions: entry[directions]!,                                                                     affiliation: "OTHERS", discount_id: entry[discount_id]!))
                        }
                    }
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == discountPickerView {
            return discountType.count
        }
        return affiliation.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == discountPickerView {
            return discountType[row]
        }
        return affiliation[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == discountPickerView {
            discountTypeTxt.text = discountType[row]
            discountTypeTxt.resignFirstResponder()
        } else {
            affiliationTxt.text = affiliation[row]
            affiliationTxt.resignFirstResponder()
        }
    }
}

