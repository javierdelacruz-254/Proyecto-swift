//
//  PedidoViewController.swift
//  TodoList
//
//  Created by jhossel on 17/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PedidoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var numeroMesa: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var pedidoTableView: UITableView!
    @IBOutlet weak var agregarButton: UIButton!
    
    var mesaSeleccionada: Mesa?
    var productosEnPedido: [ProductoFirestore] = []
    var total : Double = 0.0
    var nombreMozo: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
        
        pedidoTableView.delegate = self
        pedidoTableView.dataSource = self
        
        let nombres = UserDefaults.standard.string(forKey: "nombres") ?? "Nombre no disponible"
        nombreMozo = nombres
    }
    
    func setupUi(){
        if let mesa = mesaSeleccionada{
            numeroMesa.text = "Mesa: \(mesa.numero ?? "N/A")"
        }
        
        totalLabel.text = "S/. 0.00"
    }
    
    @IBAction func guardarPedido(_ sender: Any) {
        guard !productosEnPedido.isEmpty else {
            let alert = UIAlertController(title: "Pedido vacio", message: "No puedes agregar si no hay productos en el pedido", preferredStyle: .alert)
            let aceptarAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            alert.addAction(aceptarAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let mesa = mesaSeleccionada else {
            print("No hay mesa seleccionada")
            return
        }
        
        let pedido: [String: Any] = [
            "mesa": mesa.numero ?? "Desconocida",
            "productos": productosEnPedido.map{ producto in
                [
                    "nombre": producto.nombre ?? "Sin nombre",
                    "precio": producto.precio ?? 0.0,
                    "categoria": producto.categoria ?? "Sin categoria",
                    "cantidad": producto.categoria,
                    "subtotal": producto.precio
                ]
            },
            "total": total,
            "estado": "Pendiente",
            "nombreMozo": nombreMozo,
            "fecha": Timestamp(date: Date())
        ]
        db.collection("pedido").addDocument(data: pedido) {error in
            if let error = error {
                print("Error al guardar el pedido: \(error.localizedDescription)")
            }else {
                print("Pedido guardado correctamente")
                self.db.collection("mesa").document(mesa.id).updateData(["estado": "Ocupado"]){ error in
                    if let error = error {
                        print("Error al actualizar el estado de la mesa: \(error.localizedDescription)")
                    }else{
                        print("Estado de la mesa actualizado a 'Ocupado'")
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productosEnPedido.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PedidoCell", for: indexPath) as! PedidoTableViewCell
        let producto = productosEnPedido[indexPath.row]
        cell.nombreProductoLabel.text = producto.nombre
        cell.precioProductoLabel.text = "S/. \(producto.precio)"
        return cell
    }
    
    @IBAction func navegarProductos(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pedidoVC = storyboard.instantiateViewController(withIdentifier: "productoViewController") as? ProductoViewController{
            self.navigationController?.pushViewController(pedidoVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let eliminarAction = UIContextualAction(style: .destructive, title: "Eliminar"){_,_, completionHandler in
                   let producto = self.productosEnPedido[indexPath.row]
                   
                   let alert = UIAlertController(title: "Eliminar producto", message: "¿Deseas eliminar cierta cantidad o todo", preferredStyle: .alert)
                   
                   alert.addTextField{ textField in
                       textField.keyboardType = .numberPad
                       textField.placeholder = "Cantidad a eliminar"
                   }
                   
                   let eliminarCantidadAction = UIAlertAction(title: "Eliminar Cantidad", style: .default){_ in
                       if let cantidadText = alert.textFields?.first?.text, let cantidad = Int(cantidadText), cantidad > 0{
                           let subtotalEliminar = producto.precio / Double(cantidad)
                           self.total -= subtotalEliminar
                           self.totalLabel.text = "S/. \(String(format: "%.2f", self.total))"
                           
                           self.productosEnPedido.removeAll(where: {$0.id == producto.id})
                       }
                   }
                   
                   let eliminarTodoAction = UIAlertAction(title: "Eliminar todo", style: .destructive){_ in
                       self.total -= producto.precio
                       self.totalLabel.text = "S/. \(String(format: "%.2f", self.total))"
                       self.productosEnPedido.remove(at: indexPath.row)
                       self.pedidoTableView.deleteRows(at:[indexPath], with: .automatic)
                   }
                   
                   let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                   
                   alert.addAction(eliminarCantidadAction)
                   alert.addAction(eliminarTodoAction)
                   alert.addAction(cancelarAction)
                       
                   self.present(alert, animated: true, completion: nil)
                   completionHandler(true)
               }
               
               eliminarAction.backgroundColor = .red
               return UISwipeActionsConfiguration(actions: [eliminarAction])
    }
    
    /*
    func agregarProducto(producto: ProductoEntitiy) {
        productosEnPedido.append(producto)
        total += producto.precio
        totalLabel.text = "S/. \(String(format: "%2f", total))"
        pedidoTableView.reloadData()
    }
     */
    
    
    
    

    

}
