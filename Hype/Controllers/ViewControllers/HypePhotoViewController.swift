//
//  HypePhotoViewController.swift
//  Hype
//
//  Created by Lee McCormick on 2/4/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hypeTitleTextField: UITextField!
    @IBOutlet weak var photoContainerView: UIView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Properties
    var image: UIImage?
    
    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeTitleTextField.text, !text.isEmpty,
              let image = self.image else { return }
        HypeController.shared.createHype(with: text, photo: image) { (result) in
            guard let _ = try? result.get() else { return } //Short hand for swift result, not recommented by Max
            self.dismissView()
        }
    }
    
    // MARK: - Helper Fuctions
    func setupViews() {
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 10
        photoContainerView.clipsToBounds = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
} // End of class

// MARK: - Extensions
extension HypePhotoViewController: PhotoSelectorDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
}
