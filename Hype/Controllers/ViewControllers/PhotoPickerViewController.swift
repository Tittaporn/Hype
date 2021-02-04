//
//  PhotoPickerViewController.swift
//  Hype
//
//  Created by Lee McCormick on 2/4/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import UIKit

// MARK: - Protocol
// Create Protocol to communicate between view
protocol PhotoSelectorDelegate: AnyObject {
    func photoPickerSelected(image: UIImage)
}

class PhotoPickerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Properties
    let imagePicker = UIImagePickerController()
    weak var delegate: PhotoSelectorDelegate?
    
    // MARK: - Actions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        // Adding alert to prompt the user for camera or galerry.
        let alert = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openGallery()
        }
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func setupViews() { //Using programatic for the views.
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .black
        imagePicker.delegate = self
    }
}

// MARK: - Extensions
// we need 2 classes for PickerImage ==> UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        // we check if camera is source, then present imagePicker.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else { //Camera Source is not available.
            let alert = UIAlertController(title: "No camera access", message: "Plese allow access to the Camera to use this feature", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    func openGallery() {
        // we check if photoLibrary is source, then present imagePicker.
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else { //photoLibrary Source is not available.
            let alert = UIAlertController(title: "No photo access", message: "Plese allow access to the Photos to use this feature", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            
            // Make sure it has delegate and assign the delegate for the protocol
            guard let delegate = delegate else { return }
            delegate.photoPickerSelected(image: pickedImage)
            photoImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
