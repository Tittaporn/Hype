//
//  HypeListViewController.swift
//  Hype
//
//  Created by Lee McCormick on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    // Using refresher on setupViews()
    var refresher: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    // MARK: - Actions
    @IBAction func createdHypeButtonTapped(_ sender: Any) {
        presentHypeAlert(hype: nil)
    }
    
    // MARK: - Helper Fuctions
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        refresher.attributedTitle = NSAttributedString(string: "Pull to see new Hypes!")
        
        // add target to refresher
        // Need @objc infront of func loadData() because of  #selector(loadData)
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        // add refresher to tableView using .addSubview(refresher)
        tableView.addSubview(refresher)
    }
    
    func updateViews() {
        // loadData() ==> Cause infinished loop
        tableView.reloadData()
    }
    
    @objc func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            case .success(let response):
                print(response)
                self.updateViews()
            case .failure(_):
                print("There was an error fetching hypes.")
            }
        }
        // Telling the refresher to stop running
        self.refresher.endRefreshing()
    }
    
    // Putting Hype for parameter to create hype or update hype
    func presentHypeAlert(hype: Hype?) {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is hype may never die!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            // Create placholder for textField
            textField.placeholder = "What is Hype today?"
            
            // Add configuration to textField
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            textField.delegate = self
            
            // if we have hype, we are updating the hype
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            // Getting the text in the textField from only or first textField and make sure it is not empty.
            guard let text = alertController.textFields?.first?.text,
                  !text.isEmpty else { return }
            
            // if we have hype called the update func in HypeController
            if let hype = hype {
                hype.body = text
                HypeController.shared.update(hype: hype) { (result) in
                    switch result {
                    case .success(let response):
                        print(response)
                        
                        DispatchQueue.main.async {
                            // update the hypes on Views. by using loadData()
                            self.loadData()
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } else { // if we DO NOT have hype then create the hype
                HypeController.shared.createHype(with: text, photo: nil) { (result) in
                    switch result {
                    case .success(let response):
                        print(response) //print the Result Successfully String in HypeController.shared.createHype() method == "Successfully save a Hype."
                        self.updateViews() // Then  called updateViews func
                    case .failure(_):
                        print("There was an error saving a new hype.")
                    }
                }
            }
        }
        // Add anything to alertController
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: true) // And present the alert
    }
}

// MARK: - Extensions UITableViewDelegate, UITableViewDataSource
extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HypeController.shared.hypes.count
        //return HypeController.shared.hypes.count // DO NOT NEED return if a single line of code to return
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Can not gaurd here because hype for cell might be optional, so the return just use ??
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath) as? HypeTableViewCell
        let hype = HypeController.shared.hypes[indexPath.row]
        cell?.hype = hype
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hypeToDelete = HypeController.shared.hypes[indexPath.row]
            
            // need the index to delete, but not need this line to use equable and then more complicated, THEN JUST USE indexPath.row
            //guard let index = HypeController.shared.hypes.first
            
            HypeController.shared.delete(hype: hypeToDelete) { (result) in
                switch result {
                case .success(let response):
                    print(response)
                    DispatchQueue.main.async {
                        // remove from S.O.T., using the indexPath.row
                        HypeController.shared.hypes.remove(at: indexPath.row)
                        // tell table to delete the row
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // Using didSelectRowAt for updating
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find the hypeToUpdate by selected row and and call presentAlert to update
        let hypeToUpdate = HypeController.shared.hypes[indexPath.row]
        presentHypeAlert(hype: hypeToUpdate)
    }
}

extension HypeListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField ==> This textFild Refer to every textField in the View, if we use the textField with the outlet name. It is only refer to that specific outlet
        textField.resignFirstResponder()
        return true
    }
}
