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
        presentCreateHypeAlert()
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
    
    func presentCreateHypeAlert() {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is hype may never die!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            // Create placholder for textField
            textField.placeholder = "What is Hype today?"
            
            // Add configuration to textField
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            // Getting the text in the textField from only or first textField and make sure it is not empty.
            guard let text = alertController.textFields?.first?.text,
                  !text.isEmpty else { return }
            
            HypeController.shared.createHype(with: text) { (result) in
                switch result {
                case .success(let response):
                    print(response) //print the Result Successfully String in HypeController.shared.createHype() method == "Successfully save a Hype."
                    self.updateViews() // Then  called updateViews func
                case .failure(_):
                    print("There was an error saving a new hype.")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = "\(hype.timestamp)"
        return cell
    }
    
    
}
