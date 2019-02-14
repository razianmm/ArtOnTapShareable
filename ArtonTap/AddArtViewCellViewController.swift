//
//  AddArtViewCellViewController.swift
//  ArtonTap
//
//  Created by user on 2019-02-14.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class AddArtViewCellViewController: UIViewController  {
    
    var artToAdd: UIImage?
    @IBOutlet weak var nameOfBeer: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var artistName: UITextField!
    @IBOutlet weak var notesOnBeer: UITextView!
    
    @IBOutlet weak var artImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        artImageView.image = artToAdd
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
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
