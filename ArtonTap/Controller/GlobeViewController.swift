//
//  GlobeViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-26.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class GlobeViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var globeView: MKMapView!
    
    var artArray = [BeerArt]()
    
    var user: User?
    
    var beerCoordinates = [MKPointAnnotation]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBeerArtArray()
        
        for beer in artArray {
            
            let latitude = beer.whereLatitude
            
            let longitude = beer.whereLongitude
            
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            
            let annotation = MKPointAnnotation()
            
            annotation.title = beer.nameOfBeer
            
            annotation.coordinate = location

            beerCoordinates.append(annotation)
            
        }
        
        let worldRegion = MKCoordinateRegion(MKMapRect.world)
        
        globeView.region = worldRegion
        
        globeView.addAnnotations(beerCoordinates)

    }
    
    func loadBeerArtArray() {
        
        if let name = user?.userName {
            
            let request: NSFetchRequest<BeerArt> = BeerArt.fetchRequest()
            
            let predicate = NSPredicate(format: "addedBy == %@", name)
            
            request.predicate = predicate
            
            do {
                
                artArray = try context.fetch(request)
                
            } catch {
                
                print("Error loading data: \(error)")
                
            }
            
        }
    }

}
