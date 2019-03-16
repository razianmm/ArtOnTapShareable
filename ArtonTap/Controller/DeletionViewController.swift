//
//  DeletionViewController.swift
//  ArtonTap
//
//  Created by user on 2019-03-16.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

class DeletionViewController: UIViewController {
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    
    let ref = Database.database().reference()
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let fileManager = FileManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteAllFromLocalStorage(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Warning!", message: "This will delete all saved items from lcoal storage. Items saved to online database will persist. Are you sure you wish to contine?", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes, delete all from local storage", style: .default, handler: { (UIAlertAction) in
            
            self.deleteAllFromLocalStorageFunction() { result in
                
                if result == 0 {
                    
                    let alert = UIAlertController(title: "Deletion Complete", message: "All locally saved items deleted", preferredStyle: .alert)
                    
                    alert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        
                        alert.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true)
                    
                } else {
                    
                    let alert = UIAlertController(title: "Error", message: "Unable to delete all items from store. Please try again", preferredStyle: .alert)
                    
                    alert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        
                        alert.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true)
                    
                }
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        present(alert, animated: true)
        
        
    }
    
    @IBAction func deleteAllFromDatabase(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Warning", message: "This will delete all items saved by user in online database. Locally saved items will persist. Do you still wish to continue?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, delete all items from online database", style: .default, handler: { (UIAlertAction) in
            
            self.deleteAllObjectsFromFirebaseDatabase {
                
                self.ref.child(self.userID!).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if snapshot.hasChildren() == true {
                        
                        let failAlert = UIAlertController(title: "Failure", message: "Could not delete all items in database, please try again or contact database administrator", preferredStyle: .alert)
                        
                        failAlert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            
                            failAlert.dismiss(animated: true, completion: nil)
                            
                        }))
                        
                        self.present(failAlert, animated: true)
                        
                    } else {
                        
                        let successAlert = UIAlertController(title: "Success", message: "All items in online database deleted", preferredStyle: .alert)
                        
                        successAlert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            
                            successAlert.dismiss(animated: true, completion: nil)
                            
                        }))
                        
                        self.present(successAlert, animated: true)
                        
                    }
                    
                })
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        present(alert, animated: true)
        
    }
    
    //MARK: - Deletion methods
    
    func deleteAllFromLocalStorageFunction(completion: @escaping (_ success: Int) -> ()) {
        
        var allLocalItems = [BeerArt]()
        
        var beerCount = 0
        
        let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
        
        do {
            
            beerCount = try self.context.count(for: request)
            
            allLocalItems = try self.context.fetch(request)
            
            for items in allLocalItems {
                
                self.context.delete(items)
                
                try fileManager.removeItem(at: documentsPath[0].appendingPathComponent(items.beerArt ?? ""))
                
                beerCount = beerCount - 1
                
                print("Beer item deleted from local storage")
                
            }
            
            try self.context.save()
            
            print("context saved")
            
        } catch {
            
            print("Error accessing local store context")
            
        }
        
        completion(beerCount)
        
    } // end of function
    
    func deleteAllObjectsFromFirebaseDatabase(completion: @escaping () -> Void) {
        
        SVProgressHUD.show()
        
        let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
        
        do {
            
            let beers = try context.fetch(request)
            
            for beer in beers {
                
                self.deleteObjectFromFirebaseCloud(object: beer)
                
                if let objectToDelete = beer.nameOfBeer {
                    
                    let dataLocation = ref.child(userID!).child(objectToDelete)
                    
                    dataLocation.removeValue()
                    
                }
                
            }
            
            SVProgressHUD.dismiss()
            
            completion()
            
        } catch {
            
            print("Error accessing database")
            
        }
        
    }
    
    func deleteObjectFromFirebaseCloud(object: BeerArt) {
        
        let storageRef = storage.reference()
            
            if let fileToDelete = object.imagePath {
                
                let fileRef = storageRef.child(fileToDelete)
                
                fileRef.delete { error in
                    
                    if let error = error {
                        
                        print("Error deleting file: \(error)")
                        
                    } else {
                        
                        print("Image removed from Cloud Storage successfully")
                        
                    }
                    
                }
                
            }
            
        }
        
}

