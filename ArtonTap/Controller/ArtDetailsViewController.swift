//
//  ArtDetailsViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-15.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ArtDetailsViewController: UIViewController {
    
    //Variables related to Firebase
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    
    let ref = Database.database().reference()
    
    //Variables related to local storage
    
    var beerArt: BeerArt?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let fileManager = FileManager()
    
    @IBOutlet weak var artView: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var whereDrank: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var notesOnBeer: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let beerArtObject = beerArt {
            
            if let beerImageName = beerArtObject.beerArt {
                
                let imageURL = documentsPath[0].appendingPathComponent(beerImageName)
                
                do {
                    
                    let data = try Data(contentsOf: imageURL)
                    
                    let image = UIImage(data: data)
                    
                    artView.image = image
                    
                } catch {
                    
                    print("Error loading image data: \(error)")
                    
                }
                
            }
            
            beerName.text = beerArtObject.nameOfBeer
            whereDrank.text = beerArtObject.whereDrank
            artistName.text = beerArtObject.artistName
            notesOnBeer.text = "Notes: \(String(describing: beerArtObject.notes ?? ""))"
        }
        
    }
    
    @IBAction func deleteArt(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete from database?", message: "Would you like to delete this item from the online database as well, or just locally?", preferredStyle: .alert)
        
        let deleteFromDatabaseAction = UIAlertAction(title: "Delete from both database and locally", style: .default) { (UIAlertAction) in
            
            self.deleteObjectFromFirebaseCloud()
            
            self.deleteObjectFromFirebaseDatabase()
            
            self.deleteObjectFromContext()
            
            self.performSegue(withIdentifier: "backToCollection", sender: self)
            
        }
        
        let deleteFromLocalContext = UIAlertAction(title: "Delete from local storage only", style: .default) { (UIAlertAction) in
            
            self.deleteObjectFromContext()
            
            self.performSegue(withIdentifier: "backToCollection", sender: self)
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(deleteFromDatabaseAction)
        
        alert.addAction(deleteFromLocalContext)
        
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
        
    }
    
    //MARK: - Art deletion methods
    
    func deleteObjectFromContext() {
        
        if let beerArtObject = beerArt {
            
            if let fileName = beerArtObject.beerArt {
                
                context.delete(beerArtObject)
                
                do {
                    
                    try context.save()
                    
                    try fileManager.removeItem(at: documentsPath[0].appendingPathComponent(fileName))
                    
                } catch {
                    
                    print("Error deleting beer art object")
                    
                }
                
            }
            
        }
        
    }
    
    func deleteObjectFromFirebaseCloud() {
        
        let storageRef = storage.reference()
        
        if let beerArtObject = beerArt {
            
            if let fileToDelete = beerArtObject.imagePath {
                
                let fileRef = storageRef.child(fileToDelete)
                
                print(fileRef)
                
                fileRef.delete { error in
                    
                    if let error = error {
                        
                        print("Error deleting file: \(error)")
                        
                    } else {
                        
                        //                            print("Image removed from Cloud Storage successfully")
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    func deleteObjectFromFirebaseDatabase() {
        
        if let beerArtObject = beerArt {
            
            if let objectToDelete = beerArtObject.nameOfBeer {
                
                let dataLocation = ref.child(userID!).child(objectToDelete)
                
                dataLocation.removeValue()
                
            }
        }
        
    }
    
}
