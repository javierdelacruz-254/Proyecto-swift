//
//  TareasViewController.swift
//  TodoList
//
//  Created by DAMII on 26/11/24.
//

import UIKit
import CoreData

enum TipoOpe{
    case registro
    case editar
}

enum Filtro{
    case todos
    case fecha
    case prioridad
}

class TareasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tareasTableView: UITableView!
    @IBOutlet weak var searchView: UISearchBar!
    
    @IBOutlet weak var buttonFilterAll: UIButton!
    @IBOutlet weak var buttonFilterDate: UIButton!
    @IBOutlet weak var buttonFilterPriority: UIButton!

    var tareasList : [TareaEntity] = []
    var tareasFiltradas : [TareaEntity] = []
    
    var currentFilter : Filtro = .todos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tareasTableView.dataSource = self
        tareasTableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(actualizarListadoTareas), name: Notification.Name("TareaRegistrada"), object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(actualizarListadoTareas), name: Notification.Name("TareaEliminada"), object: nil)
        searchView.delegate = self
        listCoreData()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TareaRegistrada"), object: nil)
    }
    
    @objc func actualizarListadoTareas(){
        listCoreData()
    }
    
    
    @IBAction func filterAll(_ sender: Any) {
        currentFilter = .todos
        aplicarFiltro()
    }
    
    @IBAction func filterDate(_ sender: Any) {
        currentFilter = .fecha
        aplicarFiltro()
    }
    
    @IBAction func filterPriority(_ sender: Any) {
        currentFilter = .prioridad
        aplicarFiltro()
    }
    
    func aplicarFiltro(){
        switch currentFilter {
        case .todos:
            tareasFiltradas = tareasList
        case .fecha:
            let todayStart = getStartOfToday()
            tareasFiltradas = tareasList.filter { tarea in
                guard let fechaVencimiento = tarea.fechaVencimiento else {
                    return false
                }
                return fechaVencimiento >= todayStart
            }
                tareasFiltradas.sort{ $0.fechaVencimiento ?? Date() < $1.fechaVencimiento ?? Date()}
        case .prioridad:
            tareasFiltradas = tareasList.sorted{ (tarea1, tarea2) -> Bool in
                let prioridades = ["Alta", "Media", "Baja"]
                guard let prioridad1 = tarea1.prioridad, let prioridad2 = tarea2.prioridad else {
                    return false
                }
                return prioridades.firstIndex(of: prioridad1)! < prioridades.firstIndex(of: prioridad2)!
            }
        }
        tareasTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tareasFiltradas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tareasCell", for: indexPath) as! TareasTableViewCell
        let tarea = tareasFiltradas[indexPath.row]
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = .medium
        dateFormatt.timeStyle = .short
        
        dateFormatt.timeZone = TimeZone(identifier: "America/Lima")
        
        if let fecha = tarea.fechaVencimiento {
            cell.fechaTarea.text = dateFormatt.string(from: fecha)
        }else {
            cell.fechaTarea.text = "Fecha no disponible"
        }
        cell.tituloTarea.text = tarea.nombre
        cell.descripcionTarea.text = tarea.descripcion
        cell.prioridadTarea.text = tarea.prioridad
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tareas = tareasFiltradas[indexPath.row]
        goToDetail(tarea: tareas)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            listCoreData()
        }else{
            searchCoreData(search: searchText)
        }
    }
    
    private func goToDetail(tarea: TareaEntity){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "tareaDetalleView") as!
        TareaDetalleViewController
        view.tarea = tarea
        self.navigationController?.pushViewController(view, animated: true)
    }
    
}

extension TareasViewController {
    func getStartOfToday() -> Date {
            let calendar = Calendar.current
            let now = Date()
            return calendar.startOfDay(for: now)
    }
}

extension TareasViewController {
    func listCoreData(){
        let delegate = UIApplication.shared.delegate as!  AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        do{
            let tareas = try
            context.fetch(TareaEntity.fetchRequest())
            self.tareasList = tareas
            aplicarFiltro()
        } catch let error as NSError {
            print("Error: \(error.description)")
        }
        tareasTableView.reloadData()
    }
    
    func searchCoreData(search: String){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<TareaEntity> = TareaEntity.fetchRequest()
        let predicate = NSPredicate(format: "nombre CONTAINS[c] %@", search)
        request.predicate = predicate
        do{
            let result = try context.fetch(request)
            self.tareasFiltradas = result
        }catch let error as NSError {
            print("Error: \(error.description)")
        }
        self.tareasTableView.reloadData()
    }
}
