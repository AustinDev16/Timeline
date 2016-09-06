//
//  NewPostTableViewController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class NewPostTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
        captionTextField.returnKeyType = .Done
        
       
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
        return true
    }

    @IBAction func selectImageButtonTapped(sender: AnyObject) {
        // TODO: - implement actual photo picker
        //let path = NSBundle.mainBundle().pathForResource("musikverein", ofType: "JPEG")
        let selectedImage = UIImage(named: "musikverein")
        self.photoImageView.image = selectedImage
        
        selectImageButton.hidden = true
        
    }
    
    
    @IBAction func addPostButtonTapped(sender: AnyObject) {
        guard let caption = captionTextField.text where caption.characters.count > 0,
            let photo = photoImageView.image else {
                
                // present error alert if fields are not present
                let notEnoughInfoAlert = UIAlertController(title: "Could not create post", message: "Please pick an image and/or add a caption.", preferredStyle: .Alert)
                
                let okay = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                notEnoughInfoAlert.addAction(okay)
                presentViewController(notEnoughInfoAlert, animated: true, completion: nil)
                
                return
        }
        
        PostController.sharedController.createPost(photo, caption: caption)
        print(PostController.sharedController.posts.count)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }



 

}
