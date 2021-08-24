//
//  DealCell.swift
//  DealTime
//
//  Created by Nishant  Dalmia on 08/03/21.
//

import UIKit

class DealCell: UITableViewCell {
    
    @IBOutlet weak var providerLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
