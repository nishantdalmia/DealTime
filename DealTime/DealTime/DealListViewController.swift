//
//  DealListViewController.swift
//  DealTime
//
//  Created by Nishant Dalmia on 07/03/21.
//

import UIKit

class DealListViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var dealsTableView: UITableView!
    @IBOutlet weak var searchBarQuery: UISearchBar!
    
    struct Deal{
        var provider: String
        var discount: String
        var directions: String
        var affiliation: String
        var discount_id: Int
    }
    var category = String()
    var deals = [Deal(provider: "Provider", discount: "Discount", directions: "Directions", affiliation: "Affiliation", discount_id: 0)]
    var searchFilteredDeals = [Deal(provider: "Provider", discount: "Discount", directions: "Directions", affiliation: "Affiliation", discount_id: 0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "DealCell", bundle: nil)
        dealsTableView.register(nib, forCellReuseIdentifier: "DealCell")
        dealsTableView.delegate = self
        dealsTableView.dataSource = self
        searchBarQuery.delegate = self
        
        categoryLbl.text = category
        searchFilteredDeals = deals
    }
}

extension DealListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchFilteredDeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath) as! DealCell
        cell.providerLbl.text = searchFilteredDeals[indexPath.row].provider
        cell.discountLbl.text = searchFilteredDeals[indexPath.row].discount
        
        if (indexPath.row % 2 == 0) {
            cell.contentView.layer.borderColor = UIColor.blue.cgColor
        }
        else {
            cell.contentView.layer.borderColor = UIColor.yellow.cgColor
        }
        cell.contentView.layer.borderWidth = 4
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deal_view = storyboard?.instantiateViewController(identifier: "DealViewController") as! DealViewController
        deal_view.category = category
        deal_view.provider = searchFilteredDeals[indexPath.row].provider
        deal_view.discount = searchFilteredDeals[indexPath.row].discount
        deal_view.directions = searchFilteredDeals[indexPath.row].directions
        deal_view.affiliation = searchFilteredDeals[indexPath.row].affiliation
        deal_view.discount_id = searchFilteredDeals[indexPath.row].discount_id
        
        present(deal_view, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFilteredDeals = searchText.isEmpty ? deals : deals.filter { (item: Deal) -> Bool in
            return item.provider.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        dealsTableView.reloadData()
    }
}
