//
//  PedidoListaTableViewCell.swift
//  TodoList
//
//  Created by DAMII on 20/12/24.
//

import UIKit

class PedidoListaTableViewCell: UITableViewCell {

    @IBOutlet weak var numeroMesaLabel: UILabel!
    @IBOutlet weak var nombreMozoLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
