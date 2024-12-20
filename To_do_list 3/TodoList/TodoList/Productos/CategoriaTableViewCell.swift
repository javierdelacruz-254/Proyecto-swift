//
//  CategoriaTableViewCell.swift
//  TodoList
//
//  Created by jhossel on 17/12/24.
//

import UIKit

class CategoriaTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource{


    @IBOutlet weak var productoCollection: UICollectionView!
    
    @IBOutlet weak var nombreCateLabel: UILabel!
    
    var productos: [ProductoEntitiy] = [] {
        didSet{
            print("Productos asignados: \(productos)")
            productoCollection.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productoCollection.delegate = self
        productoCollection.dataSource = self
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productoCollection.dequeueReusableCell(withReuseIdentifier: "ProductoCell", for: indexPath) as! ProductoCollectionViewCell
        let producto = productos[indexPath.row]
        cell.nombreLabel.text = producto.nombre
        cell.precioLabel.text = "S/. \(producto.precio)"
        return cell
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }

}
