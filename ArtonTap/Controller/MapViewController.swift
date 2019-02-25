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
    
    let geoCoder = CLGeocoder()
    
    var locationTitle: String?
    
//    var pinView: MKAnnotationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(userCoordinate)
        
        mapView.delegate = self
        
        createUserLocationPin()
        
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
            
            let button = UIButton(type: .contactAdd)
            
            button.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
            
            annotationView.rightCalloutAccessoryView = button
            
            locationTitle = annotation.title!
            
            return annotationView
            
        } else {
        
            return nil
            
        }
        
    }
    
    @objc func addLocation(sender: UIButton) {
        
//        performSegue(withIdentifier: "addLocation", sender: self)
    
        let previousView = self.navigationController?.viewControllers[1] as! AddArtViewCellViewController
        
        previousView.location.text = locationTitle
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        let destinationVC = segue.destination as! AddArtViewCellViewController
//
//        destinationVC.locationName = locationTitle
//
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        let draggedView = view.annotation as! MKPointAnnotation
        
            if newState == .none {
            
                if let userLatitude = view.annotation?.coordinate.latitude {
                
                    if let userLongitude = view.annotation?.coordinate.longitude {
                    
                        newLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
                    
                        geoCoder.reverseGeocodeLocation(newLocation!) { (placemarks, error) in
                        
                        let placeName = placemarks?[0].name
                        
                        draggedView.title = placeName
                            
                        draggedView.subtitle = ""
                        
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
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        createUserLocationPin()
        
    }
    
    func createUserLocationPin() {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = userCoordinate!
        
//        annotation.title = "You Are Here!"
        
        let userLocation = CLLocation(latitude: userCoordinate!.latitude, longitude: userCoordinate!.longitude)
        
        geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            
            let placeName = placemarks?[0].name
            
            annotation.title = placeName ?? "You are here!"
            
            self.locationTitle = annotation.title
            
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
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
            
            annotation.subtitle = "\(city) \(state)"
            
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}


