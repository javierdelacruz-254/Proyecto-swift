//
//  TareasTableViewCell.swift
//  TodoList
//
//  Created by DAMII on 26/11/24.
//

import UIKit

class TareasTableViewCell: UITableViewCell {

    @IBOutlet weak var tituloTarea: UILabel!
    @IBOutlet weak var descripcionTarea: UILabel!
    @IBOutlet weak var fechaTarea: UILabel!
    @IBOutlet weak var prioridadTarea: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
