//
//  UsuarioViewController.swift
//  TodoList
//
//  Created by jhossel on 19/12/24.
//

import UIKit

class UsuarioViewController: UIViewController {

    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var apellidosTextField: UITextField!
    @IBOutlet weak var codigoUsuario: UILabel!
    @IBOutlet weak var correoTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cargarInformacionUsuario()
        
    }
    
    private func cargarInformacionUsuario(){
        let nombres = UserDefaults.standard.string(forKey: "nombres") ?? "Nombre no disponible"
        let apellidos = UserDefaults.standard.string(forKey: "apellidos") ?? "Apellidos no disponible"
        let correo = UserDefaults.standard.string(forKey: "correo") ?? "Correo no disponible"
        let id = UserDefaults.standard.string(forKey: "id") ?? "El id no existe"
        codigoUsuario.text = "Codigo: \(id)"
        nombreTextField.text = nombres
        apellidosTextField.text = apellidos
        correoTextField.text = correo
    }
    

    @IBAction func cerrarSesion(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "login")
        UserDefaults.standard.removeObject(forKey: "nombre")
        UserDefaults.standard.removeObject(forKey: "apellidos")
        UserDefaults.standard.removeObject(forKey: "correo")
        UserDefaults.standard.removeObject(forKey: "id")
        
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginView") as? LoginViewController else{
            return
        }
        
        if let appDelegate = view.window?.windowScene?.delegate as? SceneDelegate{
            appDelegate.window?.rootViewController = loginVC
        }
        
        loginVC.modalTransitionStyle = .flipHorizontal
        present(loginVC, animated: true, completion: nil)
           
    }
    

}
