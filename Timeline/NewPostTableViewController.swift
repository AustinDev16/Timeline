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
        captionTextField.returnKeyType = .done
        imagePicker.delegate = self
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
        return true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        photoImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        selectImageButton.isHidden = true
    }
    
    @IBAction func selectImageButtonTapped(_ sender: AnyObject) {
        // TODO: - implement actual photo picker
        //let path = NSBundle.mainBundle().pathForResource("musikverein", ofType: "JPEG")
//        let selectedImage = UIImage(named: "musikverein")
//        self.photoImageView.image = selectedImage
//        
//        selectImageButton.hidden = true

        let photoTypeActionSheet = UIAlertController(title: "Select photo from:", message: nil, preferredStyle: .actionSheet)
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            // photo library stuff
            
   //        imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
            
            
        }
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        photoTypeActionSheet.addAction(cancel)
        photoTypeActionSheet.addAction(photoLibrary)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        
            photoTypeActionSheet.addAction(camera)}
        present(photoTypeActionSheet, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addPostButtonTapped(_ sender: AnyObject) {
        guard let caption = captionTextField.text , caption.characters.count > 0,
            let photo = photoImageView.image else {
                
                // present error alert if fields are not present
                let notEnoughInfoAlert = UIAlertController(title: "Could not create post", message: "Please pick an image and/or add a caption.", preferredStyle: .alert)
                
                let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                notEnoughInfoAlert.addAction(okay)
                present(notEnoughInfoAlert, animated: true, completion: nil)
                
                return
        }
        
        PostController.sharedController.createPost(photo, caption: caption)
        print(PostController.sharedController.posts.count)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }



 

}
