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
import FirebaseDatabase
import FirebaseStorage
import ChameleonFramework
import SVProgressHUD

class ArtCollectionTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Variables related to Firebase
    
    let ref = Database.database().reference()
    
    let storage = Storage.storage()
    
    let userID = Auth.auth().currentUser?.uid
    
    //Variables related to taking and saving images
    
    let imagePicker = UIImagePickerController()
    
    var pickedImage: UIImage?
    
    //Variables related to TableView and manipulating data
    
    var artArray = [BeerArt]()
    
    var beerArt: BeerArt?
    
    var user: User?
    
    //Misc. variables
    
    let dispatchGroup = DispatchGroup()
    
    var documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        
        self.navigationItem.title = "My Beer Art Collection"
        
        loadBeerArtArray()
        
//        if artArray.count == 0 {
//            
////            self.tableView.reloadData()
//            
//            let alert = UIAlertController(title: "No beers found", message: "No beers were found in local storage, would you like to download saved beers from database?", preferredStyle: .alert)
//            
//            alert.addAction(UIAlertAction(title: "Yes, sync with database", style: .default, handler: { (UIAlertAction) in
//                
//                self.syncBeerArtArray(download: self.downloadImages)
//                
//                
//            }))
//            
//            alert.addAction(UIAlertAction(title: "No, continue locally", style: .default, handler: { (UIAlertAction) in
//                
//                alert.dismiss(animated: true, completion: nil)
//                
//            }))
//            
//            present(alert, animated: true)
//            
//        }
//            
////        } else {
////
////            self.tableView.reloadData()
////
////        }
        
        let worldVC = self.tabBarController?.viewControllers?[1] as! GlobeViewController
        
        worldVC.user = user
        
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
            
            let image = UIImage(contentsOfFile: imageURL.path)
            
            let imageView = UIImageView(image: image)
            
            imageView.contentMode = .scaleAspectFill
            
            cell.backgroundView = imageView
            
            let averageImageColor = UIColor(averageColorFrom: image)
            
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: averageImageColor, isFlat: true)
            
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
            
            destinationVC.user = user
            
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
    
    @IBAction func unwindFromArtDetailsView(sender: UIStoryboardSegue) {
        
        loadBeerArtArray()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        if artArray.count == 0 {
            
            //            self.tableView.reloadData()
            
            let alert = UIAlertController(title: "No beers found", message: "No beers were found in local storage, would you like to download saved beers from database?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes, sync with database", style: .default, handler: { (UIAlertAction) in
                
                self.syncBeerArtArray(download: self.downloadImages)
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "No, continue locally", style: .default, handler: { (UIAlertAction) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            present(alert, animated: true)
            
        }
        
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

            if let name = user?.userName {
            
                let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
                
                let predicate = NSPredicate(format: "addedBy == %@", name)
                
                request.predicate = predicate
                
                do {
                    
                    artArray = try self.context.fetch(request)
                    
                    self.tableView.reloadData()
                    
                } catch {
                    
                    print("Error loading data from context")
                    
                }
                        
            }
                
    }
    
    //MARK: - Firebase methods to log out and to sync data from database

    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        
        do {
            
            try Auth.auth().signOut()
            
            performSegue(withIdentifier: "logOut", sender: self)
            
        } catch {
            
            print("Error signing out")
            
        }
        
    }
    
    func syncBeerArtArray(download: @escaping () -> Void) {
        
        SVProgressHUD.show()
        
        var artistName: String = ""
        var beerName: String = ""
        var locationDrank: String = ""
        var notesOnBeer: String = ""
        var addedBy: String = ""
        var imagePath: String = ""
        var latitude: Double = 0
        var longitude: Double = 0
        
        ref.child(userID!).observeSingleEvent(of: .value) { (DataSnapshot) in
            
            if let value = DataSnapshot.value as? NSDictionary {
                    
                    for (_, values) in value {
                        
                        self.dispatchGroup.enter()
                        
                        if let beers = values as? NSDictionary {
                            
                            artistName = beers.value(forKey: "artist-name") as? String ?? ""
                            beerName = beers.value(forKey: "beer-name") as? String ?? ""
                            locationDrank = beers.value(forKey: "location-drank") as? String ?? ""
                            notesOnBeer = beers.value(forKey: "notes-on-beer") as? String ?? ""
                            addedBy = beers.value(forKey: "added-by") as? String ?? ""
                            imagePath = beers.value(forKey: "image-location") as? String ?? ""
                            latitude = beers.value(forKey: "latitude") as? Double ?? 0
                            longitude = beers.value(forKey: "longitude") as? Double ?? 0
                            
                            
                            //Core Data implementation in method - move to seperate function?
                            
                            let savedBeer = BeerArt(context: self.context)
                            
                            savedBeer.nameOfBeer = beerName
                            savedBeer.artistName = artistName
                            savedBeer.whereDrank = locationDrank
                            savedBeer.notes = notesOnBeer
                            savedBeer.beerArt = beerName + ".jpeg"
                            savedBeer.addedBy = addedBy
                            savedBeer.imagePath = imagePath
                            savedBeer.whereLatitude = latitude
                            savedBeer.whereLongitude = longitude
                            
                            do {
                                
                                try self.context.save()
                                
                                print("Beer saved")
                                
                            } catch {
                                
                                print("Error saving new beer from database: \(error)")
                                
                            }
                            
                            self.artArray.append(savedBeer)
                            
                            self.dispatchGroup.leave()
                            
                        }
                    }
            }
            
            self.dispatchGroup.notify(queue: .main) {
                
                download()
                
            }
        
        }
        
    }

    
    func downloadImages() {
        
        for beers in artArray {
            
            if let pathName = beers.imagePath {
                
                if let name = beers.nameOfBeer {
                    
                    let pathReference = storage.reference(withPath: pathName)
                    
                    let fileName = name + ".jpeg"
                    
                    let localfileURL = documentsPath[0].appendingPathComponent(fileName)
                    
                    dispatchGroup.enter()
                    
                    DispatchQueue.global().async {
                        
                        let downloadTask = pathReference.write(toFile: localfileURL) { url, error in
                         
                            if error != nil {
                                
                                print("Error downloading image: \(String(describing: error))")
                            
                            } else {
                                
                                print(url)
                                
                            }
                        
                            self.dispatchGroup.leave()
                            
                        }
                        
                    }
                        
                }
                        
            }
                            
        }
        
        dispatchGroup.notify(queue: .main) {
            
            SVProgressHUD.dismiss()
            
            print("All images downloaded")
            
            self.tableView.reloadData()
            
        }
                    
    } // end of last function
            
          
                
}



