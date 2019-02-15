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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        
        loadBeerArtArray()
        
        tableView.reloadData()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return artArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "artCell", for: indexPath)
        
        cell.textLabel?.text = artArray[indexPath.row].nameOfBeer
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            let destinationVC = segue.destination as! AddArtViewCellViewController
            
//            destinationVC.artImageView?.image = pickedImage
        
            destinationVC.artToAdd = pickedImage
        
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        performSegue(withIdentifier: "addArt", sender: self)
        
    }
    
    func loadBeerArtArray() {
        
         let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
        
        do {
            
            artArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading data: \(error)")
            
        }
    }

}

