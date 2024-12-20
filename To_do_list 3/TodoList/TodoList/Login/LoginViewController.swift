//
//  LoginViewController.swift
//  TodoList
//
//  Created by DAMII on 12/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var claveTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func login(_ sender: Any) {
        //alertas que me digan que el correo no es valido o contrasena no es valido
        let email = emailTextField.text!
        let password = claveTextField.text!
        loginFirebase(email: email, password: password)
        
    }
    
    private func loginFirebase(email: String, password: String) {
        // Validar si los campos están vacíos
        if email.isEmpty && password.isEmpty {
            // Si alguno de los campos está vacío, mostramos una alerta
            showAlert(message: "Datos vacíos. Por favor, rellene ambos campos.")
            return // Salimos de la función para evitar continuar con el proceso de login
        }
        
        let auth = Auth.auth()
        auth.signIn(withEmail: email, password: password) { result, error in
            if let user = result {
                // Si el inicio de sesión es exitoso, obtenemos el UID del usuario
                let uid = user.user.uid
                self.searchUserFirestore(uid: uid)
                self.goToMenu()
            } else {
                // Si no se puede iniciar sesión, mostramos una alerta con el error
                var errorMessage = "Se produjo un error desconocido. Intenta nuevamente."
                
                if let error = error {
                    // Personalizar el mensaje de error dependiendo del código de error
                    if let errorCode = AuthErrorCode(rawValue: error._code) {
                        switch errorCode {
                        case .wrongPassword:
                            errorMessage = "Clave Vacia. Por favor,ingrese una clave."
                        case .invalidEmail:
                            errorMessage = "Correo Vacio. Por favor, ingrese un correo válido."
                        default:
                            errorMessage = "Datos incorrectos. Por favor, verifica tu correo y contraseña."
                        }
                    }
                }
                
                // Mostrar la alerta con el mensaje de error
                self.showAlert(message: errorMessage)
            }
        }
    }
    
    // Función para mostrar una alerta
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alertController.addAction(acceptAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func searchUserFirestore(uid:String){
        let db = Firestore.firestore()
        db.collection("usuarios").document(uid).getDocument{(document,error) in
            if let error = error {
                print("Se presenton  un error")
            }else if let document = document, document.exists{
                let data = document.data()
                let nombres = data?["nombres"]as? String ?? ""
                let apellidos = data?["apellidos"]as? String ?? ""
                let email = data?["correo"]as? String ?? ""
                
                UserDefaults.standard.setValue(true, forKey: "login")
                UserDefaults.standard.setValue(uid, forKey: "id")
                UserDefaults.standard.setValue(nombres, forKey: "nombres")
                UserDefaults.standard.setValue(apellidos, forKey: "apellidos")
                UserDefaults.standard.setValue(email, forKey: "correo")
                
                
                
                
                
                print(nombres)
                print(apellidos)
                print(email)
            }
        }
    }
    var window: UIWindow?
    private func goToMenu() {
        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "mesasView") as? UITabBarController {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }else {
                print("No se pudo encontrar el SceneDelegate o la ventana principal")
            }
        }
    }
}
