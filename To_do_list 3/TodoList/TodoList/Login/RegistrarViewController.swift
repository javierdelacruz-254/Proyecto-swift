//
//  RegistrarViewController.swift
//  TodoList
//
//  Created by DAMII on 12/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrarViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var claveTextField: UITextField!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var apellidoTextFIeld: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func registrar(_ sender: Any) {
        let nombres = nombreTextField.text!
        let apellidos = apellidoTextFIeld.text!
        let email = emailTextField.text!
        let clave = claveTextField.text!
        
        if nombres.isEmpty || apellidos.isEmpty || email.isEmpty || clave.isEmpty {
            // Si algún campo está vacío, mostramos la alerta y salimos de la función.
            showAlert(message: "Por favor, llena todos los campos.")
            return
        }
        
        // Validación del correo electrónico
        if !isValidEmail(email: email) {
            // Si el correo no es válido, mostramos la alerta y salimos de la función.
            showAlert(message: "Correo electrónico inválido. Por favor, ingresa un correo válido.")
            return
        }
        
        // Validación de la clave
        if !isValidPassword(password: clave) {
            // Si la clave no es válida, mostramos la alerta y salimos de la función.
            showAlert(message: "La contraseña debe tener al menos 8 caracteres, una mayúscula y un signo especial.")
            return
        }
        registrarFirebase(nombres: nombres, apellidos: apellidos, email: email, clave: clave)
    }
    
    private func registrarFirebase(nombres:String,apellidos:String,email:String,clave:String){
        let auth = Auth.auth()
        auth.createUser(withEmail: email, password: clave){ result, error in
            if let error = error {
                if let authError = error as? NSError{
                    if authError.code == AuthErrorCode.emailAlreadyInUse.rawValue{
                        self.showAlert(message: "El correo electrónico ya está registrado. Por favor, usa otro correo.")
                    }else{
                            self.showAlert(message: "Se presentó un error al crear la cuenta. \(error.localizedDescription)")                    }
                }
                return
            }
            if let user = result{
                let uid = user.user.uid
                self.registrarFirestore(uid: uid, nombre: nombres, apellidos: apellidos, email: email)
            }
            
        }
        
    }
    
    private func registrarFirestore(uid:String, nombre:String,apellidos:String,email:String){
        let db = Firestore.firestore()
        db.collection("usuarios").document(uid).setData([
            "nombres":nombre,
            "apellidos":apellidos,
            "correo": email
        ]){error in
            if let error = error{
                self.showAlert(message: "Se presento un erro al guardar los datos.\(error.localizedDescription)")
            }else{
                self.showAlert(message: "¡Registro exitoso!") {
                    self.redirectToLogin()
                }            }
            
        }
    }
    
    private func isValidEmail(email: String) -> Bool {
        // Usamos una expresión regular simple para validar el correo
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // Función para validar la contraseña
    private func isValidPassword(password: String) -> Bool {
        // La contraseña debe tener al menos 8 caracteres, una mayúscula y un signo especial.
        let passwordRegex = "^(?=.*[A-Z])(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    // Función para mostrar alertas
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Atención", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Función para redirigir a la vista de login
    private func redirectToLogin() {
        // Usamos el storyboard para realizar la transición al login
        if let storyboard = self.storyboard {
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginView") as? LoginViewController {
                // Redirigir al login
                self.navigationController?.setViewControllers([loginViewController], animated: true)
            }
        }
    }
    
}
