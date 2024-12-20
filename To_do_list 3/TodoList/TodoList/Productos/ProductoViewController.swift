//
//  ProductoViewController.swift
//  TodoList
//
//  Created by jhossel on 18/12/24.
//

import UIKit
import FirebaseFirestore

struct ProductoFirestore{
    let id: String
    let nombre: String
    let categoria: String
    let precio: Double
}

class ProductoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    

    @IBOutlet weak var productoTableView: UITableView!
    
    @IBOutlet weak var searchProducto: UISearchBar!
    @IBOutlet weak var todoFilter: UIButton!
    @IBOutlet weak var entradaFilter: UIButton!
    @IBOutlet weak var segundoFilter: UIButton!
    @IBOutlet weak var bebidaFilter: UIButton!
    
    var productos: [ProductoFirestore] = []
    var filteredProducto: [ProductoFirestore] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productoTableView.dataSource = self
        productoTableView.delegate = self
        searchProducto.delegate = self
        
        fetchProductos()
        
    }
        func fetchProductos() {
            let db = Firestore.firestore()
            db.collection("producto").getDocuments(){ (querySnapshot, error) in
                if let error = error {
                    print("Error al obtener los productos \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No se encontraron documentos en la coleccion")
                    return
                }
                self.filteredProducto = documents.compactMap{ document in
                    let data = document.data()
                    guard let nombre = data["nombre"] as? String,
                    let categoria = data["categoria"] as? String,
                    let precio = data["precio"] as? Double else {
                        print("Error al mapear los datos del documento: \(document.documentID)")
                        return nil
                    }
                    return ProductoFirestore(id: document.documentID, nombre: nombre, categoria: categoria, precio: precio)
                }
                print("Productos obtenidos de Firestore: \(self.filteredProducto.count)")
                for producto in self.filteredProducto{
                    print("Nombre: \(producto.nombre), Categoria: \(producto.categoria), Precio: S/. \(producto.precio)")
                }
                
                self.productoTableView.reloadData()
            }
        }
    
    @IBAction func todoFiltrado(_ sender: Any) {
        filterTodo()
    }
    
    @IBAction func entradaFiltrado(_ sender: Any) {
            filterEntrada()
    }
    
    @IBAction func segundoFiltrado(_ sender: Any) {
        filterSegundo()
    }
    
    @IBAction func bebidaFiltrado(_ sender: Any) {
        filterBebidas()
    }
    
    func filterTodo(){
        fetchProductos()
    }
    
    func filterEntrada(){
        filteredProducto = productos.filter{$0.categoria == "Entrada"}
        DispatchQueue.main.async {
            self.productoTableView.reloadData()
        }
    }
    
    func filterSegundo(){
        filteredProducto = productos.filter{$0.categoria == "Segundo"}
        DispatchQueue.main.async {
            self.productoTableView.reloadData()
        }
    }
    
    func filterBebidas(){
        filteredProducto = productos.filter{$0.categoria == "Bebidas"}
        DispatchQueue.main.async {
            self.productoTableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            fetchProductos()
        }else {
            filteredProducto =
            productos.filter{$0.nombre.lowercased().contains(searchText.lowercased())}
            
            DispatchQueue.main.async{
                self.productoTableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let producto = filteredProducto[indexPath.row]
        
        let cell = productoTableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath) as! ProductoTableViewCell
        cell.nombreProductoLabel.text = producto.nombre
        cell.precioProductoLabel?.text = "S/. \(producto.precio)"
        cell.categoriaLabel.text = producto.categoria
        
        print("Configurando celda: Nombre = \(producto.nombre ?? "Sin nombre"), Categoría = \(producto.categoria ?? "Sin categoría"), Precio = S/. \(producto.precio)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let agregarAction = UITableViewRowAction(style: .normal, title: "Agregar") {(action, indexPath) in
                    
                    let productoSeleccionado = self.productos[indexPath.row]
                    
                    let alertCantidad = UIAlertController(title: "Agregar Plato", message: "Ingresar la cantidad", preferredStyle: .alert)
                    alertCantidad.addTextField{textField in
                        textField.keyboardType = .numberPad
                        textField.placeholder = "Cantidad"
                    }
                    
                    let agregarButton = UIAlertAction(title: "Agregar", style: .default){_ in
                        if let cantidadText = alertCantidad.textFields?.first?.text, let cantidad = Int(cantidadText), cantidad > 0 {
                            if let pedidoVC = self.navigationController?.viewControllers.first(where: {$0 is PedidoViewController}) as? PedidoViewController {
                                let subtotal = productoSeleccionado.precio * Double(cantidad)
                                
                                let productosEnPedido = ProductoFirestore(id: productoSeleccionado.id, nombre: "\(productoSeleccionado.nombre) (x\(cantidad))", categoria: productoSeleccionado.categoria, precio: subtotal
                                )
                                
                                pedidoVC.productosEnPedido.append(productosEnPedido)
                                pedidoVC.total += subtotal
                                pedidoVC.totalLabel.text = "S/. \(String(format: "%.2f", pedidoVC.total))"
                                
                                pedidoVC.pedidoTableView.reloadData()
                                
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            let alertaExito = UIAlertController(title: "Agregado", message: "El producto fue agregado exitosamente.", preferredStyle: .alert)
                            alertaExito.addAction(UIAlertAction(title: "Aceptar", style: .default))
                            self.present(alertaExito, animated: true)
                        }else{
                            let alertaError = UIAlertController(title: "Error", message: "Por favor, ingrese una cantidad", preferredStyle: .alert)
                            alertaError.addAction(UIAlertAction(title: "Aceptar", style: .default))
                            self.present(alertaError, animated: true)
                        }
                    }
                    let cancelButton = UIAlertAction(title: "Cancelar", style: .cancel)
                    alertCantidad.addAction(cancelButton)
                    alertCantidad.addAction(agregarButton)
                    self.present(alertCantidad, animated: true)
                }
                
                agregarAction.backgroundColor = UIColor.systemGreen
                return [agregarAction]
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productos[indexPath.row]
        
        if let pedidoVC = navigationController?.viewControllers.first(where: {$0 is PedidoViewController}) as? PedidoViewController {
            pedidoVC.agregarProducto(producto: productoSeleccionado)
            navigationController?.popViewController(animated: true)
        }
    }
    */
    func showAlert(){
        
    }
    
}
