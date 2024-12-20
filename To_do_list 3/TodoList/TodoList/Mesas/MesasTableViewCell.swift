//
//  MesasTableViewCell.swift
//  TodoList
//
//  Created by jhossel on 16/12/24.
//

import UIKit

class MesasTableViewCell: UITableViewCell {

    @IBOutlet weak var numeroLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
