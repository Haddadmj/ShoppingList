//
//  OnlineListViewController.swift
//  ShoppingList
//
//  Created by Mohammad Al-haddad on 12/01/2022.
//

import UIKit
import FirebaseAuth

class OnlineListViewController: UITableViewController {
    
    var userList : [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseManager.shared.getOnlineUsers(completion: {
            [weak self] result in
            switch result {
            case .success(let users):
                self?.userList = users
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    
    @IBAction func signoutButtonPressed(_ sender: UIBarButtonItem) {
        do{
            DatabaseManager.shared.removeUser()
            try Auth.auth().signOut()
        }catch{
            print(error.localizedDescription)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        cell.textLabel?.text = userList[indexPath.row].email

        return cell
    }
    
}
