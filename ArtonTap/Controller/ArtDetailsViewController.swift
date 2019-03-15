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
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    
    let ref = Database.database().reference()
    
    var beerArt: BeerArt?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let fileManager = FileManager()
    
    @IBOutlet weak var artView: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var whereDrank: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var beerNotes: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let beerArtObject = beerArt {
            
            if let beerImageName = beerArtObject.beerArt {
        
                let imageURL = documentsPath[0].appendingPathComponent(beerImageName)
                
    //            print(imageURL)
                
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
            beerNotes.text = beerArtObject.notes
                
            }
        
    }
    
    
    @IBAction func deleteArt(_ sender: UIButton) {
        
        deleteObjectFromFirebaseCloud()
        
        deleteObjectFromFirebaseDatabase()
        
        deleteObjectFromContext()
        
        performSegue(withIdentifier: "backToCollection", sender: self)
        
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
                            
                            print("Image removed from Cloud Storage successfully")
                            
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
