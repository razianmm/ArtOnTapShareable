//
//  LogInViewController.swift
//  ArtonTap
//
//  Created by user on 2019-03-01.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInScreenViewController: UIViewController {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        if let email = userEmail.text, let password = userPassword.text {
        
            if email.count > 0 && password.count > 0 {
            
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    
                    if user != nil && error == nil {
                        
                        self.performSegue(withIdentifier: "goToApp", sender: self)
                        
                    } else if error != nil {
                        
                        print("Error signing user in: \(error)")
                        
                    }
                }
            }
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        
        let alert = UIAlertController(title: "Sign Up New User", message: "Please Enter Your E-mail Address and a Password to Continue", preferredStyle: .alert)
        
        alert.addTextField { (emailTextField) in
            
            emailTextField.placeholder = "Enter your e-mail address"
            
        }
        
        alert.addTextField { (passwordTextField) in
            
            passwordTextField.placeholder = "Enter a password"
            
        }
        
        let emailTextField = alert.textFields![0]
        
        let passwordTextField = alert.textFields![1]
        
        let signUpAction = UIAlertAction(title: "Sign Me Up!", style: .default) { (UIAlertAction) in
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                
                if error == nil {

                    Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                        
                        if user != nil, error == nil {
                            
                            self.performSegue(withIdentifier: "goToApp", sender: self)
                            
                        } else if error != nil {
                            
                            print("Error signing user in: \(error)")
                            
                        }

                    })

                } else {

                    print("Error signing up: \(error)")

                }
                
            })
            
        }
        
        alert.addAction(signUpAction)
        
        present(alert, animated: true)
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
