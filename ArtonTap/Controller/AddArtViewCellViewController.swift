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
import MapKit

class AddArtViewCellViewController: UIViewController, CLLocationManagerDelegate  {
    
//    var didFindLocation: Bool?
    
    var fileLocation: String?
    
    var artToAdd: UIImage?
    
    let locationManager = CLLocationManager()
    
    var newBeer: BeerArt?
    
    var userCoordinate: CLLocationCoordinate2D?
    
    var locationName: String?
    
    @IBOutlet weak var nameOfBeer: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var artistName: UITextField!
    @IBOutlet weak var notesOnBeer: UITextView!
    @IBOutlet weak var artImageView: UIImageView!
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        artImageView.image = artToAdd
        
        if locationName != nil {
            
            location.text = locationName
            
        }
        
//        let documentsPath = files.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
//        SVProgressHUD.show()
        
        saveImage()
        
        addBeer()
        
    }
    
    func saveImage() {

        if nameOfBeer.text?.isEmpty == false {

            let imageFileName = nameOfBeer.text! + ".jpeg"
            
            let imageToStore = artToAdd!.jpegData(compressionQuality: 0.5)

            let newDocument = documentsPath[0].appendingPathComponent(imageFileName)

            do {

                try imageToStore?.write(to: newDocument)
                
                print("Image saved successfully")
                print(newDocument)

            } catch {

                print("Error saving image: \(error)")

            }

        } else {

            let alert = UIAlertController(title: "No name found", message: "Please give this beer a name before saving it", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)

        }
        
        
    }
    
    func addBeer() {
        
            newBeer = BeerArt(context: context)

            newBeer?.nameOfBeer = nameOfBeer.text

            newBeer?.whereDrank = location.text

            newBeer?.artistName = artistName.text

            newBeer?.notes = notesOnBeer.text
        
//        newBeer.beerArt = documentsPath[0].appendingPathComponent("\(nameOfBeer.text!)" + ".jpeg").path
        
        if let fileLocation = nameOfBeer.text {
        
            newBeer?.beerArt = "\(fileLocation)" + ".jpeg"
            
            print(newBeer)
            
        }
       
        do {
            
            try context.save()
            
            print("New beer art item saved successfuly")
            
            print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
            
        } catch {
            
            print("Error saving new beer art item: \(error)")
            
        }
        
        
        performSegue(withIdentifier: "artAdded", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "artAdded" {
            
            let destinationVC = segue.destination as! ArtCollectionTableViewController
            
            if let beerToAdd = newBeer {
            
            destinationVC.artArray.append(beerToAdd)
                
            }
            
        } else if segue.identifier == "showMap" {
            
            let destinationVC = segue.destination as! MapViewController
            
            destinationVC.userCoordinate = userCoordinate
            
        }
        
        
    }
    
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
