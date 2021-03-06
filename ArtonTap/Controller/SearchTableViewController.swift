//
//  SearchTableViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-24.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchTableViewController: UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    
    var userCoordinate: CLLocationCoordinate2D?
    
    var handleMapSearchDelegate: HandleMapSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchingItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        cell.textLabel?.text = selectedItem.name
        
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - UISearchResultUpdating methods

extension SearchTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let coordinates = userCoordinate,
            let searchBarText = searchController.searchBar.text else { print("Error in mapView or searchBar"); return }
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchBarText
        
        request.region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            
            guard let response = response else { print("Error with response"); return }
            
            self.matchingItems = response.mapItems
            
            self.tableView.reloadData()
        }
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
