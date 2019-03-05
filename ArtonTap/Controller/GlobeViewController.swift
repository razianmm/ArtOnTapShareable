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

class GlobeViewController: UIViewController {
    
    @IBOutlet weak var globeView: MKMapView!
    
    var artArray = [BeerArt]()
    
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
            
            annotation.coordinate = location

            beerCoordinates.append(annotation)
            
        }
        
        let worldRegion = MKCoordinateRegion(MKMapRect.world)
        
        globeView.region = worldRegion
        
        globeView.addAnnotations(beerCoordinates)

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
