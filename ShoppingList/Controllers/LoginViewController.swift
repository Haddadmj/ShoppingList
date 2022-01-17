//
//  ViewController.swift
//  ShoppingList
//
//  Created by Mohammad Al-haddad on 12/01/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passwordField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let apperance = UINavigationBarAppearance()
        apperance.configureWithOpaqueBackground()
        apperance.backgroundColor = .systemTeal
        navigationController?.navigationBar.standardAppearance = apperance
        navigationController?.navigationBar.scrollEdgeAppearance = apperance
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func clearTextFields(){
        emailField.text = nil
        passwordField.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if Auth.auth().currentUser == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.performSegue(withIdentifier: "MainView", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func loginButtonPressed(_ sender:UIButton){
        validateAuth(true)
    }
    
    @IBAction func registerButtonPressed(_ sender:UIButton){
        validateAuth(false)
    }
    
    func validateAuth(_ bool:Bool){
        guard let email = emailField.text, let pass = passwordField.text, !email.isEmpty, !pass.isEmpty else {
            return
        }
        
        if bool {
            Auth.auth().signIn(withEmail: email, password: pass, completion: {
                [weak self] _, error in
                
                guard error == nil else {
                    self?.showAlert(title: "Login Error", message: String(describing: error?.localizedDescription))
                    return
                }
                
                DatabaseManager.shared.insertUser(of: email)
                
                self?.clearTextFields()
                self?.performSegue(withIdentifier: "MainView", sender: nil)
            })
            
        }else {
            Auth.auth().createUser(withEmail: email, password: pass, completion: {
                [weak self] _, error in
                
                guard error == nil else {
                    self?.showAlert(title: "Register Error", message: String(describing: error?.localizedDescription))
                    return
                }
                
                DatabaseManager.shared.insertUser(of: email)
                self?.clearTextFields()
                self?.performSegue(withIdentifier: "MainView", sender: nil)
                
            })
            
        }
    }


}

extension LoginViewController {
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

