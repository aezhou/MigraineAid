//
//  BasicCell.swift
//  MigraineAid
//
//  Created by Amanda Zhou on 11/10/15.
//  Copyright © 2015 Amanda Zhou. All rights reserved.
//

import UIKit

class BasicCell: UITableViewCell {
    @IBOutlet var timeLabel : UILabel!
    @IBOutlet var locationlabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}