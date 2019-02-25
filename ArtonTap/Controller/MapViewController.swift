//
//  MapViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark)
    
}

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate {
    
    var searchController: UISearchController? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    var userLocations = [UserLocations]()
    
    var userPin: UserLocations?
    
    var userCoordinate: CLLocationCoordinate2D?
    
    var newLocation: CLLocation?
    
    var selectedPin: MKPlacemark?
    
//    var pinView: MKAnnotationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(userCoordinate)
        
        mapView.delegate = self
        
        let region = MKCoordinateRegion.init(center: userCoordinate!, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        mapView.region = region
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = userCoordinate!
        
        annotation.title = "You Are Here!"
        
        annotation.subtitle = "Cheers"
        
        mapView.addAnnotation(annotation)
        
        //Code for the search table:
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! SearchTableViewController
        
        locationSearchTable.userCoordinate = userCoordinate
        
        locationSearchTable.handleMapSearchDelegate = self
        
        searchController = UISearchController(searchResultsController: locationSearchTable)
        
        searchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = searchController!.searchBar
        
        searchBar.sizeToFit()
        
        searchBar.placeholder = "Search for places"
        
        navigationItem.titleView = searchController?.searchBar
        
        searchController?.hidesNavigationBarDuringPresentation = false
        
        searchController?.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myUserPin")
            
            annotationView.pinTintColor = UIColor.blue
            annotationView.isDraggable = true
            annotationView.animatesDrop = true
            annotationView.canShowCallout = true
            
            return annotationView
            
        } else {
        
            return nil
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        let draggedView = view.annotation as! MKPointAnnotation
        
            if newState == .none {
            
                if let userLatitude = view.annotation?.coordinate.latitude {
                
                    if let userLongitude = view.annotation?.coordinate.longitude {
                    
                        newLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
                    
                        let geoCoder = CLGeocoder()
                    
                        geoCoder.reverseGeocodeLocation(newLocation!) { (placemarks, error) in
                        
                        let placeName = placemarks?[0].name
                        
                        draggedView.title = placeName
                        
                        }
                    
                    }
                
                }
            
            }
        
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

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = placemark.coordinate
        
        annotation.title = placemark.name
        
        if let city = placemark.locality, let state = placemark.administrativeArea {
            
            annotation.subtitle = "(city) (state)"
            
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
}


