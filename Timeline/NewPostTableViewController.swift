//
//  NewPostTableViewController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class NewPostTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
        captionTextField.returnKeyType = .Done
        imagePicker.delegate = self
       
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
        return true
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        photoImageView.image = selectedImage
        
        dismissViewControllerAnimated(true, completion: nil)
        selectImageButton.hidden = true
    }
    
    @IBAction func selectImageButtonTapped(sender: AnyObject) {
        // TODO: - implement actual photo picker
        //let path = NSBundle.mainBundle().pathForResource("musikverein", ofType: "JPEG")
//        let selectedImage = UIImage(named: "musikverein")
//        self.photoImageView.image = selectedImage
//        
//        selectImageButton.hidden = true

        let photoTypeActionSheet = UIAlertController(title: "Select photo from:", message: nil, preferredStyle: .ActionSheet)
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .Default) { (_) in
            // photo library stuff
            
   //        imagePicker.delegate = self
            self.imagePicker.sourceType = .PhotoLibrary
            self.imagePicker.allowsEditing = false
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        photoTypeActionSheet.addAction(cancel)
        photoTypeActionSheet.addAction(photoLibrary)
        presentViewController(photoTypeActionSheet, animated: true, completion: nil)
        
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
