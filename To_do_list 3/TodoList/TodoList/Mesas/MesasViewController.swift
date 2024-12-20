//
//  MesasViewController.swift
//  TodoList
//
//  Created by jhossel on 16/12/24.
//

import UIKit
import FirebaseFirestore

struct Mesa{
    let id: String
    let numero: String
    let estado: String
}

class MesasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
 
    @IBOutlet weak var MesastableView: UITableView!
    @IBOutlet weak var disponibleFilter: UIButton!
    @IBOutlet weak var searchMesa: UISearchBar!
    @IBOutlet weak var ocupadoFilter: UIButton!
    
    var mesas: [Mesa] = []
    var filteredMesa: [Mesa] = []
    var selectedMesa: Mesa?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MesastableView.delegate = self
        MesastableView.dataSource = self
        searchMesa.delegate = self

        listarMesas()
        filterDisponible()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMesa.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mesasCell", for: indexPath) as! MesasTableViewCell
        let mesas = filteredMesa[indexPath.row]
        cell.numeroLabel?.text = mesas.numero
        cell.estadoLabel?.text = mesas.estado
        
        if mesas.estado == "Ocupado" {
            cell.isUserInteractionEnabled = false
            cell.contentView.alpha = 0.5
        }else {
            cell.isUserInteractionEnabled = true
            cell.contentView.alpha = 1.0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mesa = filteredMesa[indexPath.row]
        
        if mesa.estado != "Ocupado"{
            selectedMesa = mesa
            let stoyboard = UIStoryboard(name: "Main", bundle: nil)
            if let pedidoVC = stoyboard.instantiateViewController(withIdentifier: "pedidoViewController") as? PedidoViewController{
                pedidoVC.mesaSeleccionada = selectedMesa
                self.navigationController?.pushViewController(pedidoVC, animated: true)
            }
        }
    }
    @IBAction func filtrarDisponibles(_ sender: Any) {
        filterDisponible()
    }
    
    @IBAction func filtrarOcupados(_ sender: Any) {
        filterOcupadas()
    }
    
    func filterDisponible(){
        filteredMesa = mesas.filter{$0.estado == "Disponible"}
        DispatchQueue.main.async {
            self.MesastableView.reloadData()
        }
    }
    
    func filterOcupadas(){
        filteredMesa = mesas.filter { $0.estado == "Ocupado" }
        DispatchQueue.main.async {
            self.MesastableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterDisponible()
        }else {
            filteredMesa = mesas.filter{$0.numero.lowercased().contains(searchText.lowercased())}
            
            DispatchQueue.main.async {
                self.MesastableView.reloadData()
            }
        }
        
    }
    func listarMesas(){
        db.collection("mesa").order(by: "numero").addSnapshotListener{ snapshot, error in
            if let error = error {
                print("Error al listar las mesas: \(error.localizedDescription)")
                return
            }
            self.mesas = snapshot?.documents.compactMap{ document in
                let data = document.data()
                    guard let numero = data["numero"] as? String,
                          let estado = data["estado"] as? String else {
                        print("Error al mapear mesa: \(document.documentID)")
                        return nil
                    }
                return Mesa(id: document.documentID, numero: numero, estado: estado)
            } ?? []
            
            self.filterDisponible()
            
            DispatchQueue.main.async{
                self.MesastableView.reloadData()
            }
        }
    }
    
    
  
    
}

