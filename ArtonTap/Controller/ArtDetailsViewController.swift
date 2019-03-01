//
//  ArtDetailsViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-15.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ArtDetailsViewController: UIViewController {
    
    var beerArt: BeerArt?
    
     let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    @IBOutlet weak var artView: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var whereDrank: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var beerNotes: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let beerArtObject = beerArt {
            
            if let beerImageName = beerArtObject.beerArt {
        
                let imageURL = documentsPath[0].appendingPathComponent(beerImageName)
                
    //            print(imageURL)
                
                do {
                
                    let data = try Data(contentsOf: imageURL)
                    
                    let image = UIImage(data: data)
                    
                    artView.image = image
                    
                } catch {
                    
                    print("Error loading image data: \(error)")
                    
                }
                
            }

            beerName.text = beerArtObject.nameOfBeer
            whereDrank.text = beerArtObject.whereDrank
            artistName.text = beerArtObject.artistName
            beerNotes.text = beerArtObject.notes
                
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
