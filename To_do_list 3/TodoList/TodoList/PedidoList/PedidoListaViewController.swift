//
//  PedidoListaViewController.swift
//  TodoList
//
//  Created by DAMII on 20/12/24.
//

import UIKit
import FirebaseFirestore
struct Pedido {
    let numeroMesa: String
    let nombreMozo: String
    let total: Double
    let estado: String
    let fecha: Date
}
class PedidoListaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pedidoListaTableView: UITableView!
    
    var pedidos: [Pedido] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pedidoListaTableView.delegate = self
        pedidoListaTableView.dataSource = self

        fetchPedidos()
        
    }
    
    func fetchPedidos() {
          db.collection("pedido").getDocuments { snapshot, error in
              if let error = error {
                  print("Error al obtener los pedidos: \(error.localizedDescription)")
                  return
              }

              guard let documents = snapshot?.documents else {
                  print("No se encontraron pedidos.")
                  return
              }

              self.pedidos = documents.compactMap { doc in
                  let data = doc.data()
                  guard
                      let numeroMesa = data["mesa"] as? String,
                      let nombreMozo = data["nombreMozo"] as? String,
                      let total = data["total"] as? Double,
                      let estado = data["estado"] as? String,
                      let timestamp = data["fecha"] as? Timestamp
                  else {
                      return nil
                  }
                  return Pedido(
                      numeroMesa: numeroMesa,
                      nombreMozo: nombreMozo,
                      total: total,
                      estado: estado,
                      fecha: timestamp.dateValue()
                  )
              }

              DispatchQueue.main.async {
                  self.pedidoListaTableView.reloadData()
              }
          }
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pedidos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pedidoListaCell", for: indexPath) as? PedidoListaTableViewCell else {
                    return UITableViewCell()
                }

                let pedido = pedidos[indexPath.row]
                cell.numeroMesaLabel.text = pedido.numeroMesa
                cell.nombreMozoLabel.text = pedido.nombreMozo
                cell.totalLabel.text = String(format: "%.2f", pedido.total)
                cell.estadoLabel.text = pedido.estado

                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm"
                cell.fechaLabel.text = formatter.string(from: pedido.fecha)

                return cell
    }

 
}
