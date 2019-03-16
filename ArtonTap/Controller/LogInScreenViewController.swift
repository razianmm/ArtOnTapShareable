//
//  LogInViewController.swift
//  ArtonTap
//
//  Created by user on 2019-03-01.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import CoreData

class LogInScreenViewController: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var user: User?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    //MARK: - Log In method
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        if let email = userEmail.text, let password = userPassword.text {
            
            DispatchQueue.global(qos: .background).async {
                
                if email.count > 0 && password.count > 0 {
                    
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        
                        if user != nil && error == nil {
                            
                            self.fetchUser()
                            
                            DispatchQueue.main.async {
                                
                                SVProgressHUD.dismiss()
                                
                                self.performSegue(withIdentifier: "goToApp", sender: self)
                            }
                            
                        } else if error != nil {
                            
                            DispatchQueue.main.async {
                                
                                SVProgressHUD.dismiss()
                                
                                let alert = UIAlertController(title: "Error signing user in", message: "There was an error signing in, please check your information and try again", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                }))
                                
                                self.present(alert, animated: true)
                                
                            }
                        }
                    }
                    
                } else {
                    
                    let alert = UIAlertController(title: "Missing information", message: "Please fill both username and password fields to log in", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        
                        alert.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true)
                    
                }
            }
        }
    }
    
    //MARK: - Sign Up method
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Sign Up New User", message: "Please Enter Your E-mail Address and a Password to Continue", preferredStyle: .alert)
        
        alert.addTextField { (emailTextField) in
            
            emailTextField.placeholder = "Enter your e-mail address"
            
        }
        
        alert.addTextField { (passwordTextField) in
            
            passwordTextField.placeholder = "Enter a password"
            
        }
        
        let signUpAction = UIAlertAction(title: "Sign Me Up!", style: .default) { (UIAlertAction) in
            
            SVProgressHUD.show()
            
            if let email = alert.textFields![0].text, let password = alert.textFields![1].text {
                
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    
                    if error == nil {
                        
                        //Save the user locally via CoreData
                        
                        self.saveUserToCoreData(withEmail: email)
                        
                        DispatchQueue.global(qos: .default).async {
                            
                            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                                
                                if user != nil, error == nil {
                                    
                                    DispatchQueue.main.async {
                                        
                                        SVProgressHUD.dismiss()
                                        
                                        self.performSegue(withIdentifier: "goToApp", sender: self)
                                        
                                    }
                                    
                                } else if error != nil {
                                    
                                    DispatchQueue.main.async {
                                        
                                        SVProgressHUD.dismiss()
                                        
                                        print("Error signing user in: \(String(describing: error))")
                                        
                                    }
                                    
                                }
                                
                            })
                            
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            SVProgressHUD.dismiss()
                            
                            let alert = UIAlertController(title: "Sorry", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            alert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                                
                                alert.dismiss(animated: true, completion: nil)
                                
                            }))
                            
                            self.present(alert, animated: true)
                            
                            let signInAlert = UIAlertController(title: "Error signing user in", message: "There was an error signing in, please check your information and try again", preferredStyle: .alert)
                            
                            signInAlert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                                
                                signInAlert.dismiss(animated: true, completion: nil)
                                
                            }))
                            
                            self.present(alert, animated: true)
                            
                            print("Error signing up: \(String(describing: error))")
                            
                        }
                        
                    }
                    
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
            
            self.dismiss(animated: true, completion: nil)
            
        })
        
        alert.addAction(signUpAction)
        
        present(alert, animated: true)
        
    }
    
    //MARK: - Methods to fetch and save current registered user locally
    
    func fetchUser() {
        
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        
        userRequest.predicate = NSPredicate(format: "userName == %@", userEmail.text!)
        
        do {
            
            var currentUser: Array = try context.fetch(userRequest)
            
            if !currentUser.isEmpty {
                
                user = currentUser[0]
                
                //                print(user?.userName as Any)
                
            } else {
                
                user = User(context: context)
                
                user?.userName = Auth.auth().currentUser?.email
                
            }
            
        } catch {
            
            print("Error fetching user data: \(error)")
        }
        
    }
    
    func saveUserToCoreData(withEmail: String) {
        
        user = User(context: context)
        
        user?.userName = withEmail
        
        do {
            
            try context.save()
            
            //            print("New user saved successfully")
            
        } catch {
            
            print("Error saving new user: \(error)")
        }
        
        
    }
    
    //MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToApp" {
            
            let tabController = segue.destination as! UITabBarController
            
            let navController = tabController.viewControllers![0] as! UINavigationController
            
            let destinationVC = navController.topViewController as! ArtCollectionTableViewController
            
            destinationVC.user = user
            
        }
        
    }
    
    @IBAction func unwindToLogInScreen(sender: UIStoryboardSegue) {
        
        self.user = nil
        
    }
    
}
