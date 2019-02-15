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
    
    let documentsPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        artImageView.image = artToAdd
        
//        let documentsPath = files.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if se
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        saveImage()
        
        addBeer()
        
    }
    
    func saveImage() {

        if nameOfBeer.text?.isEmpty == false {

            let imageFileName = nameOfBeer.text! + ".png"
            
            let imageToStore = artToAdd!.pngData()

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
        
        let newBeer = BeerArt(context: context)

        newBeer.nameOfBeer = nameOfBeer.text

        newBeer.whereDrank = location.text

        newBeer.artistName = artistName.text

        newBeer.notes = notesOnBeer.text
        
        newBeer.beerArt = documentsPath[0].appendingPathComponent("\(nameOfBeer.text!)" + ".png").path
       
        do {
            
            try context.save()
            
            print("New beer art item saved successfuly")
            
            print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
            
        } catch {
            
            print("Error saving new beer art item: \(error)")
            
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
