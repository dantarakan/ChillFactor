//
//  TableViewCell.swift
//  ChillFactor
//
//  Created by Daniil Tarakanov on 20/08/2016.
//  Copyright © 2016 Daniil Tarakanov. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var symptom: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
