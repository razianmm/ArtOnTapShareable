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
    
    //Variable related to table for searching locations
    
    var searchController: UISearchController? = nil
    
    //Variables related to map view
    
    @IBOutlet weak var mapView: MKMapView!
    
    let geoCoder = CLGeocoder()
    
    var userPin: UserLocations?
    
    var userCoordinate: CLLocationCoordinate2D?
    
    var whereDrankCoordinate = CLLocationCoordinate2DMake(0, 0)
    
    var newLocation: CLLocation?
    
    var locationTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        createUserLocationPin()
        
        //MARK: - Search bar methods
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! SearchTableViewController
        
        locationSearchTable.userCoordinate = userCoordinate
        
        locationSearchTable.handleMapSearchDelegate = self
        
        searchController = UISearchController(searchResultsController: locationSearchTable)
        
        searchController?.searchResultsUpdater = locationSearchTable
        
        //Creating the search bar and configuring its display
        
        let searchBar = searchController!.searchBar
        
        searchBar.sizeToFit()
        
        searchBar.placeholder = "Search for places"
        
        navigationItem.titleView = searchController?.searchBar
        
        searchController?.hidesNavigationBarDuringPresentation = false
        
        searchController?.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
    }
    
    //MARK: - Create user location pin and reset to user location methods
    
    func createUserLocationPin() {
        
        let annotation = MKPointAnnotation()
        
        if let userCoordinate = userCoordinate {
            
            annotation.coordinate = userCoordinate
            
            let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
            
            geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                
                if let placeName = placemarks?[0].name {
                    
                    annotation.title = placeName
                    
                    self.locationTitle = placeName
                    
                    print(self.locationTitle)
                    
                }
                
            }
            
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        createUserLocationPin()
        
    }
    
    //MARK: - Methods to create annotation views and add location
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            
            whereDrankCoordinate = annotation.coordinate
            
            print(whereDrankCoordinate)
            
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myUserPin")
            
            annotationView.pinTintColor = UIColor.blue
            annotationView.isDraggable = true
            annotationView.animatesDrop = true
            annotationView.canShowCallout = true
            annotationView.isSelected = true
            
            let button = UIButton(type: .contactAdd)
            
            button.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
            
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
            
        } else {
            
            return nil
            
        }
        
    }
    
    @objc func addLocation(sender: UIButton) {
        
        performSegue(withIdentifier: "unwindToAddArt", sender: self)
        
    }
    
    //MARK: - Method to drag annotation pins
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        let draggedView = view.annotation as! MKPointAnnotation
        
        if newState == .none {
            
            if let userLatitude = view.annotation?.coordinate.latitude {
                
                if let userLongitude = view.annotation?.coordinate.longitude {
                    
                    newLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
                    
                    geoCoder.reverseGeocodeLocation(newLocation!) { (placemarks, error) in
                        
                        if let placeName = placemarks?[0].name {
                            
                            draggedView.title = placeName
                            
                            self.locationTitle = placeName
                            
                            self.whereDrankCoordinate = draggedView.coordinate
                            
                            print(self.locationTitle)
                            
                            draggedView.subtitle = ""
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

//MARK: - Map Search delegate methods

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = placemark.coordinate
        
        if let name = placemark.name {
            
            annotation.title = name
            
            self.locationTitle = name
            
            print(self.locationTitle)
            
        }
        
        if let city = placemark.locality, let state = placemark.administrativeArea {
            
            annotation.subtitle = "\(city) \(state)"
            
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
}


