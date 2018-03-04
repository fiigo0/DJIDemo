//
//  OrderCellTableViewCell.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 3/3/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit

class OrderCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }

}
