//
//  HypeTableViewCell.swift
//  Hype
//
//  Created by Lee McCormick on 2/4/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypeTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var hypeLabel: UILabel!
    @IBOutlet weak var hypeDateLabel: UILabel!
    @IBOutlet weak var hypeImageView: UIImageView!
    
    // == viewDidLoad for cell
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Properties
    var hype: Hype? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Helper Fuctions
    
    func setupViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.contentMode = .scaleAspectFit
        hypeImageView.layer.cornerRadius = profileImageView.frame.height / 10
        hypeImageView.contentMode = .scaleAspectFit
    }
    
    func updateViews() {
        guard let hype = hype else { return }
        hypeLabel.text = hype.body
        hypeDateLabel.text = hype.timestamp.dateToString(format: .fullNumericTimestamp)
        updateUser(for: hype)
        setImageview(for: hype)
    }
    
    func updateUser(for hype: Hype) {
        if hype.user == nil {
            UserController.sharedInstance.fetchUserFor(hype) { (result) in
                switch result {
                case .success(let user):
                    hype.user = user
                    self.setUserInfo(for: user)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setUserInfo(for user: User) {
        DispatchQueue.main.async {
            self.profileImageView.image = user.profilePhoto
            self.usernameLabel.text = user.username
        }
    }
    
    func setImageview(for hype: Hype) {
        if let hypeImage = hype.hypePhoto {
            hypeImageView.image = hypeImage
            hypeImageView.isHidden = false
        } else {
            hypeImageView.isHidden = true
        }
    }
}


