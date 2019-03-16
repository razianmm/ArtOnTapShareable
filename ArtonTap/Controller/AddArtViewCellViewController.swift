//
//  AddArtViewCellViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-14.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD
import CoreLocation
import CoreData
import MapKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import UITextView_Placeholder

class AddArtViewCellViewController: UIViewController, CLLocationManagerDelegate {
    
    var newBeer: BeerArt?
    
    // Variables related to Firebase
    
    var ref = Database.database().reference(withPath: (Auth.auth().currentUser?.uid)!)
    
    var imageRefPath: String?
    
    var storage = Storage.storage()
    
//    var doesNameAlreadyExist: Bool = false
    
    // Variables related to saving beer art image locally
    
    var fileLocation: String?
    
    var artToAdd: UIImage?
    
    var user: User?
    
    // Variables related to finding the user's location
    
    let locationManager = CLLocationManager()
    
    var userCoordinate: CLLocationCoordinate2D?
    
    var whereDrankCoordinate: CLLocationCoordinate2D?
    
    var locationName: String?
    
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var nameOfBeer: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var artistName: UITextField!
    @IBOutlet weak var notesOnBeer: UITextView!
    @IBOutlet weak var artImageView: UIImageView!
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(user?.userName)
        
        notesOnBeer.placeholder = "Add your notes here"
        
        notesOnBeer.placeholderColor = UIColor.lightGray
        
        artImageView.image = artToAdd
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        if nameOfBeer.text?.isEmpty == false {
            
            let beerName = nameOfBeer.text
            
            checkIfNameExists(withName: beerName!) { result in
            
                if result == false {
                    
                    SVProgressHUD.show()
                    
                    self.dispatchGroup.enter()
                    
                    DispatchQueue.main.async {
                    
                        self.addBeer()
                        
                        self.saveImage()
                        
                        self.saveToFirebase()
                        
                        self.dispatchGroup.leave()
                        
                    }
                    
                    self.dispatchGroup.notify(queue: .main) {
                        
                        SVProgressHUD.dismiss()
                        
                        self.performSegue(withIdentifier: "backToArtCollection", sender: self)
                        
                    }
                    
                } else {
                    
                        let alert = UIAlertController(title: "Sorry", message: "This beer name already exists either locally or in the database, please choose another", preferredStyle: .alert)
                    
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            
                            alert.dismiss(animated: true, completion: nil)
                            
                        }))
                    
                        self.present(alert, animated: true)
                    
                }
                
            }
            
        } else {
            
            let alert = UIAlertController(title: "No name found", message: "Please give this beer a name before saving it", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    } // end of addButton
    
    //MARK: - Save art image to local storage method
    
    func saveImage() {

            let imageFileName = nameOfBeer.text! + ".jpeg"
            
            let imageToStore = artToAdd!.jpegData(compressionQuality: 0.5)

            let newDocument = documentsPath[0].appendingPathComponent(imageFileName)

            do {

                try imageToStore?.write(to: newDocument)
                
                print("Image saved successfully")

            } catch {

                print("Error saving image: \(error)")

            }
        
    } //End of saveImage
    
    //MARK: - Save image to Firebase
    
    func saveImageToFirebase(name: String) {
        
        let file = name + ".jpeg"
        
        let storageRef = storage.reference()
        
        let imagesRef = storageRef.child("images").child(file)
        
        let filePathToSave = documentsPath[0].appendingPathComponent(file)
        
        let uploadTask = imagesRef.putFile(from: filePathToSave)
        
        uploadTask.observe(.success) { snapshot in
            
            print("Image uploaded successfully")
            
            self.imageRefPath = imagesRef.fullPath
            
        }
        
    } //End of saveImageToFirebase
    
    //MARK: - Add beer art method
    
    func addBeer() {
        
        if let beerName = self.nameOfBeer.text, let notes = self.notesOnBeer.text, let location = self.location.text, let artistName = self.artistName.text {
                
                self.newBeer = BeerArt(context: self.context)
                
                self.newBeer?.nameOfBeer = beerName
                
                self.newBeer?.whereDrank = location
                
                self.newBeer?.artistName = artistName
                
                self.newBeer?.notes = notes
                
                if let latitude = self.whereDrankCoordinate?.latitude {
                    
                    if let longitude = self.whereDrankCoordinate?.longitude {
                        
                        self.newBeer?.whereLatitude = latitude
                        
                        self.newBeer?.whereLongitude = longitude
                        
                    }
                    
                }
                
                self.newBeer?.beerArt = "\(beerName)" + ".jpeg"
                
                self.newBeer?.addedBy = self.user?.userName
                
                self.user?.addToArtObjects(self.newBeer!)
                
                do {
                    
                    try self.context.save()
                    
                    print("New beer art saved successfuly")
                    
                } catch {
                    
                    print("Error saving new beer art item: \(error)")
                    
                }
                
            }
        
    } //end of addBeerArt
    
    //MARK: - Save data to Firebase methods
    
    func saveToFirebase() {
        
        if let beerName = self.nameOfBeer.text, let notes = self.notesOnBeer.text, let location = self.location.text, let artistName = self.artistName.text, let addedBy = self.user?.userName, let latitude = self.whereDrankCoordinate?.latitude, let longitude = self.whereDrankCoordinate?.longitude {
            
            self.saveImageToFirebase(name: beerName)
            
            let fullImagePath = self.imageRefPath
            
            let beerNameRef = self.ref.child(beerName)
            
            beerNameRef.setValue(["beer-name" : beerName, "notes-on-beer" : notes, "location-drank" : location, "artist-name" : artistName, "image-location" : fullImagePath, "added-by" : addedBy, "latitude" : latitude, "longitude" : longitude])
            
        }
        
        
    } //end of SaveToFirebase method

    
    //MARK: - Prepare for segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMap" {
            
            let destinationVC = segue.destination as! MapViewController
            
            destinationVC.userCoordinate = userCoordinate
            
        }
        
    }
    
    //MARK: - Unwind segue method
    
    @IBAction func unwindToAddArtView(sender: UIStoryboardSegue) {
        
        let sourceVC = sender.source as! MapViewController
        
        whereDrankCoordinate = sourceVC.whereDrankCoordinate
        
        location.text = sourceVC.locationTitle
    
    }
    
    //MARK: - Show map and user location methods
    
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
        break
            
        case .denied, .restricted:
            
            let locationAlert = UIAlertController(title: "Location services disabled or restricted", message: "Please enable location services for this app to use this feature", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            locationAlert.addAction(action)
            
            present(locationAlert, animated: true, completion: nil)
            
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            
            getUserLocation()
            
            break
        
        }
        
    }
    
    func getUserLocation() {
        
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        locationManager.delegate = nil
        
        print("Did update locations")
        
        userCoordinate = locations[0].coordinate
        
        performSegue(withIdentifier: "showMap", sender: self)
        
    }
    
    //MARK: - Method to check whether beer name exists locally or in database
    
    func checkIfNameExists(withName: String, completion: @escaping (_ success: Bool) -> ()) {
        
        print("Method began")
        
        var nameExists: Bool = false
        
        let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
        
        let predicate = NSPredicate(format: "nameOfBeer == %@", withName)
        
        request.predicate = predicate
        
        do {
            
            let beer = try self.context.fetch(request)
            
                if !beer.isEmpty {
                    
                    nameExists = true
                    
                } else {
                    
                    dispatchGroup.enter()
                    
                        self.ref.child(withName).observeSingleEvent(of: .value) { snapshot in
                            
                            if snapshot.exists() {
                                
                                print("This method ran")
                                
                                nameExists = true
                        
                            }
                            
                            self.dispatchGroup.leave()
                        }
                    
                }
            
            } catch {
                    
                print("Error checking for beer name: \(error)")
                    
            }
        
        dispatchGroup.notify(queue: .main) {
        
            print("We finished")
        
            completion(nameExists)
            
        }
        
    }

}
