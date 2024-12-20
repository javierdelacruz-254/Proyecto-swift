//
//  CategoriaViewController.swift
//  TodoList
//
//  Created by jhossel on 17/12/24.
//

import UIKit
import CoreData

class CategoriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriaTableView: UITableView!
    
    var productoPorCategoria: [String : [ProductoEntitiy]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriaTableView.delegate = self
        categoriaTableView.dataSource = self
        
        verificarCategoriasPorDefecto()
        fetchProductos()
    }
    
    func verificarCategoriasPorDefecto(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
        let fetRequest : NSFetchRequest<ProductoEntitiy> = ProductoEntitiy.fetchRequest()
        
        do{
            let productosExistentes = try context.fetch(fetRequest)
            
            if productosExistentes.isEmpty{
                let productosPorDefecto: [String: [(String, Double)]] = [
                               "Entrada": [
                                   ("Ceviche clasico", 25.00),
                                   ("Leche de tigre", 18.00),
                                   ("Chicharron de calamar", 22.00)
                               ],
                               "Segundos": [
                                   ("Ceviche Mixto", 35.00),
                                   ("Arroz con Mariscos", 30.00),
                                   ("Jalea Mixta", 38.00),
                                   ("Parihuela", 33.00)
                               ],
                               "Bebidas": [
                                   ("Chicha Morada", 15.00),
                                   ("Limonada Frozen", 10.00),
                                   ("Pisco Sour", 18.00),
                                   ("Cerveza Cusqueña", 12.00)
                               ]
                           ]
                
                
                for(categoria, productos) in productosPorDefecto {
                    for(nombreProducto, precio) in productos{
                        let producto = ProductoEntitiy(context: context)
                        producto.nombre = nombreProducto
                        producto.precio = precio
                        producto.categoria = categoria
                        print("Producto agregado: \(nombreProducto) en la categoría \(categoria)")
                    }
                }
                
                do{
                    try context.save()
                    context.refreshAllObjects()
                    print("Productos guardados correctamente")
                    
                    let productosGuardados = try context.fetch(fetRequest)
                    for producto in productosGuardados{
                        print("Producto guardado:  \(producto.nombre ?? "Desconocido"), Categoria: \(producto.categoria ?? "Sin categoria")")
                    }
                }
               
            }
            
            let productos = try context.fetch(fetRequest)
            for producto in productos{
                print("Producto: \(producto.nombre ?? "Desconocido"), Categoria: \(producto.categoria ?? "Sin categoria")")
            }
            
        }catch{
            print("Error al verificar categorias: \(error.localizedDescription)")
        }
    }
    
    func fetchProductos(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<ProductoEntitiy> = ProductoEntitiy.fetchRequest()
        
        do{
            let productos = try context.fetch(fetchRequest)
            
            for producto in productos {
                        print("Producto: \(producto.nombre ?? "Desconocido"), Categoria: \(producto.categoria ?? "Sin categoria")")
                    }
            productoPorCategoria = Dictionary(grouping: productos, by: {$0.categoria ?? "Sin categoria"})
            print("Productos agrupados por categoria: \(productoPorCategoria)")
            categoriaTableView.reloadData()
        }catch{
            print("Error al cargar categorias: \(error.localizedDescription)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return productoPorCategoria.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categorias = Array(productoPorCategoria.keys)
        let categoria = categorias[section]
        return productoPorCategoria[categoria]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categorias = Array(productoPorCategoria.keys)
        return categorias[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categorias = Array(productoPorCategoria.keys)
        let categoria = categorias[indexPath.section]
        let productos = productoPorCategoria[categoria] ?? []
        
        let producto = productos[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriaCell", for: indexPath) as! CategoriaTableViewCell
        cell.nombreCateLabel?.text = producto.categoria
        cell.productos = productos
        print("Mostrando categoraia:  \(categoria)")
        return cell
    }

   

}
