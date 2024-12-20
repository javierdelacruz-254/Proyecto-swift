//
//  ProductoTableViewCell.swift
//  TodoList
//
//  Created by jhossel on 18/12/24.
//

import UIKit

class ProductoTableViewCell: UITableViewCell {

    @IBOutlet weak var nombreProductoLabel: UILabel!
    @IBOutlet weak var precioProductoLabel: UILabel!
    @IBOutlet weak var categoriaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
