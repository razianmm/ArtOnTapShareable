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
                                
                                print("Error signing user in: \(error)")
                                
                            }
                        }
                    }
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
                
                DispatchQueue.global(qos: .default).async {
            
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    
                        if error == nil {
                            
                            
                            //Save the user locally via CoreData
                            
                            self.user = User(context: self.context)
                            
                            self.user?.userName = email
                            
                            do {
                                
                                try self.context.save()
                                
                                print("New user saved successfully")
                                
                            } catch {
                                
                                print("Error saving new user: \(error)")
                            }
                            

                            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            
                                if user != nil, error == nil {
                                    
                                    DispatchQueue.main.async {
                                        
                                        SVProgressHUD.dismiss()
                                    
                                        self.performSegue(withIdentifier: "goToApp", sender: self)
                                        
                                    }
                                
                            }   else if error != nil {
                                    
                                    DispatchQueue.main.async {
                                    
                                        SVProgressHUD.dismiss()
                                
                                        print("Error signing user in: \(error)")
                                        
                                    }
                                
                            }

                            })

                        } else {
                            
                            DispatchQueue.main.async {
                                
                                SVProgressHUD.dismiss()

                                print("Error signing up: \(error)")
                                
                            }

                        }
                    
                    })
                    
                }
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(signUpAction)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
        
    }
    
    //MARK: - Methods to fetch current registered user and send information through segue
    
    func fetchUser() {
        
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        
        userRequest.predicate = NSPredicate(format: "userName == %@", userEmail.text!)

        do {
            
            var currentUser: Array = try context.fetch(userRequest)
            
            if !currentUser.isEmpty {
                
                user = currentUser[0]
                
                print(user?.userName)
                
            } else {
                
                user = User(context: context)
                
                user?.userName = Auth.auth().currentUser?.email
                
            }
            
        } catch {
            
            print("Error fetching user data: \(error)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToApp" {
            
            let tabController = segue.destination as! UITabBarController
            
            let navController = tabController.viewControllers![0] as! UINavigationController
            
            let destinationVC = navController.topViewController as! ArtCollectionTableViewController
            
            destinationVC.user = user
            
        }
        
    }
    
    @IBAction func unwindToLogInScreen(sender: UIStoryboardSegue) {
        
        let sourceVC = sender.source as! ArtCollectionTableViewController
        
        self.user = nil
        
        print(user)
        
    }

}
