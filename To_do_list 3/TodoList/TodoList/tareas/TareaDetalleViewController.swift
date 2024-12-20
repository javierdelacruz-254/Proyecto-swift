//
//  TareaDetalleViewController.swift
//  TodoList
//
//  Created by DAMII on 10/12/24.
//

import UIKit
import CoreData

class TareaDetalleViewController: UIViewController {
    @IBOutlet weak var nombreTareaDetalle: UILabel!
    @IBOutlet weak var fechaTareaDetalle: UILabel!
    @IBOutlet weak var descripcionTareaDetalle: UILabel!
    
    var tarea : TareaEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tarea = tarea {
            title = "Detalle de la tarea"
            nombreTareaDetalle.text = tarea.nombre
            let dateFormatt = DateFormatter()
            dateFormatt.dateStyle = .medium
            dateFormatt.timeStyle = .short
            
            dateFormatt.timeZone = TimeZone(identifier: "America/Lima")
            if let fecha = tarea.fechaVencimiento {
                fechaTareaDetalle.text = dateFormatt.string(from: fecha)
            }else {
                fechaTareaDetalle.text = "Fecha no disponible"
            }
            descripcionTareaDetalle.text = tarea.descripcion
        }


    }
    
    @IBAction func cancelarTarea(_ sender: Any) {
        showAlert()

    }
    
    func showAlert(){
        let alert = UIAlertController(title: "¿Estas Seguro?", message:  "Esta accion cancelara la tarea permanente.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler:{ _ in
            guard let tarea = self.tarea else {
                return
            }
            self.deleteCoreData(tarea: tarea)
            NotificationCenter.default.post(name: Notification.Name("TareaEliminada"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
                                     
    }
    
    func showErrorAlert(message: String){
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
  
}

extension TareaDetalleViewController {
    func deleteCoreData(tarea: TareaEntity){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        context.delete(tarea)
        do{
            try context.save()
        }catch let error as NSError{
            showErrorAlert(message: "Hubo un error")
        }
    }
}
