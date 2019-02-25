//
//  ViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-14.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

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
        
        let imageURL = documentsPath[0].appendingPathComponent(artArray[indexPath.row].beerArt!)
        
        do {
            
            let data = try Data(contentsOf: imageURL)
            
            let image = UIImage(data: data)
            
            let imageView = UIImageView(image: image)
            
            imageView.contentMode = .scaleAspectFill
            
            cell.backgroundView = imageView
            
        } catch {
            
            print("\(error)")
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        beerArt = artArray[indexPath.row]
        
        performSegue(withIdentifier: "artDetails", sender: self)
        
    }
    
    //MARK: - Data manipulation methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addArt" {
            
            let destinationVC = segue.destination as! AddArtViewCellViewController
        
            destinationVC.artToAdd = pickedImage
            
        } else if segue.identifier == "artDetails" {
            
            let destinationVC = segue.destination as! ArtDetailsViewController
            
            destinationVC.beerArt = beerArt!
            
        }
        
    }

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
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        performSegue(withIdentifier: "addArt", sender: self)
        
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

