//
//  ViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-14.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import ChameleonFramework

class ArtCollectionTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    var pickedImage: UIImage?
    
    var artArray = [BeerArt]()
    
    var beerArt: BeerArt?
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let user = Auth.auth().currentUser
        
        print(user)
        
        imagePicker.delegate = self
        
        self.navigationItem.title = "My Beer Art Collection"
        
        loadBeerArtArray()
        
        tableView.reloadData()
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return artArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "artCell", for: indexPath)
        
        cell.textLabel?.text = artArray[indexPath.row].nameOfBeer
        
        if let beerArtImage = artArray[indexPath.row].beerArt {
        
            let imageURL = documentsPath[0].appendingPathComponent(beerArtImage)
            
            do {
                
                let data = try Data(contentsOf: imageURL)
                
                let image = UIImage(data: data)
                
                let averageImageColor = UIColor(averageColorFrom: image)
                
                let imageView = UIImageView(image: image)
                
                imageView.contentMode = .scaleAspectFill
                
                cell.backgroundView = imageView
                
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: averageImageColor, isFlat: true)
                
            } catch {
                
                print("\(error)")
                
            }
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        beerArt = artArray[indexPath.row]
        
        performSegue(withIdentifier: "artDetails", sender: self)
        
    }
    
    //MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addArt" {
            
            let destinationVC = segue.destination as! AddArtViewCellViewController
        
            destinationVC.artToAdd = pickedImage
            
        } else if segue.identifier == "artDetails" {
            
            let destinationVC = segue.destination as! ArtDetailsViewController
            
            destinationVC.beerArt = beerArt
            
        }
        
    }
    
    @IBAction func unwindToArtCollectionView(sender: UIStoryboardSegue) {
        
        let sourceVC = sender.source as! AddArtViewCellViewController
            
        artArray.append(sourceVC.newBeer!)
        
        self.tableView.reloadData()
        
    }
    
    //MARK: - Methods to add an image

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
            
            imagePicker.sourceType = .camera
            
        } else {
        
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
        
        }
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        performSegue(withIdentifier: "addArt", sender: self)
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Core Data functions
    
    func loadBeerArtArray() {
        
         let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
        
        do {
            
            artArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading data: \(error)")
            
        }
    }

}

