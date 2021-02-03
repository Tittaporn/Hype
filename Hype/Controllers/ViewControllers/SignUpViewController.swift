//
//  SignUpViewController.swift
//  Hype
//
//  Created by Lee McCormick on 2/3/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UILabel!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    // MARK: - Actions
    @IBAction func signupButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        UserController.sharedInstance.createUserWith(username) { (result) in
            switch result {
            case .success(let user):
                guard let user = user else { return }
                UserController.sharedInstance.currentUser = user
                self.presentHypeListVC()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper Fuctions
    func fetchUser() {
        UserController.sharedInstance.fetchUer(completion:  {(result) in
            switch result {
            case .success(let user):
                UserController.sharedInstance.currentUser = user
                self.presentHypeListVC()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
}
