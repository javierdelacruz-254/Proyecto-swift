//
//  RegistrarTareaViewController.swift
//  TodoList
//
//  Created by DAMII on 10/12/24.
//

import UIKit
import CoreData

class RegistrarTareaViewController: UIViewController {
    
    @IBOutlet weak var PopUpButton: UIButton!
    @IBOutlet weak var nombreTareaLabel: UITextField!
    @IBOutlet weak var descripcionTarea: UITextField!
    @IBOutlet weak var fechaTarea: UIDatePicker!
    
    var selectedPrioridad: String? = "Media"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultPriority()
        fechaTarea.date = Date()
    
        
        let option1 = UIAction(title: "Prioridad 1 Alta", handler: { _ in 
            self.selectedPrioridad = "Alta"
            print("Opcion 1 seleccionada")})
        let option2 = UIAction(title: "Prioridad 2 - Media", handler: { _ in 
            self.selectedPrioridad = "Media"
            print("Opcion 2 seleccionada")})
        let option3 = UIAction(title: "Prioridad 3 - Baja", handler: { _ in 
            self.selectedPrioridad = "Baja"
            print("Opcion 3 seleccionada")})
        
        let menu = UIMenu(title: "", children: [option1, option2, option3])
        
        PopUpButton.menu = menu
        PopUpButton.showsMenuAsPrimaryAction = true
    }
    
    func setDefaultPriority(){
        selectedPrioridad = "Alta"
    }
    
    @IBAction func registrarTarea(_ sender: Any) {
        guard let nombre = nombreTareaLabel.text, !nombre.isEmpty else {
            showAlert(message: "El nombre de la tarea es obligatorio.")
            return
        }
        
        let descripcion = descripcionTarea.text ?? ""
        let descripcionPalabra = descripcion.split{ $0 == " " || $0.isNewline}
        if descripcionPalabra.count > 150 {
            showAlert(message: "La descripcion no debe exceder las 150 palabras")
                return
        }
        
        guard let prioridad = selectedPrioridad else {
                    showAlert(message: "Debe seleccionar una prioridad")
                    return
                }

        
        let fecha = fechaTarea.date
        if fecha < Date(){
            showAlert(message: "La fecha seleccionada no puede ser anterior a la fecha actual")
            return
        }
        
        guardarTarea(nombre: nombre, descripcion: descripcion, fecha: fecha, prioridad: prioridad)
        
    }
    
    func guardarTarea(nombre: String, descripcion: String, fecha: Date, prioridad: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let nuevaTarea = TareaEntity(context: context)
        
        nuevaTarea.nombre = nombre
        nuevaTarea.descripcion = descripcion
        nuevaTarea.fechaVencimiento = fecha
        nuevaTarea.prioridad = prioridad
        
        do{
            try context.save()
            print("Tarea registrada correctamente")
            
            NotificationCenter.default.post(name: Notification.Name("TareaRegistrada"), object: nil)
            self.dismiss(animated: true)
        } catch {
            print("Error al guardar la tarea \(error.localizedDescription)")
            showAlert(message: "Hubo un error al registrar la tarea.")
        }
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
