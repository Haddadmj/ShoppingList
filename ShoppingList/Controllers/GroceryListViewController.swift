//
//  GroceryListViewController.swift
//  ShoppingList
//
//  Created by Mohammad Al-haddad on 12/01/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GroceryListViewController: UITableViewController {
        
    var items: [Item] = []
    
    @IBOutlet weak var usersCount: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersCount.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseManager.shared.getItems(completion: {
            [weak self] result in
            switch result {
            case .success(let newItems):
                self?.items = newItems
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.showAlert(title: "Failed To Get Items", message: error.localizedDescription)
            }
        })
        
        DatabaseManager.shared.getOnlineUsers(completion: {
            [weak self] result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self?.usersCount.title = "\(users.count)"
                }
            case .failure(let error):
                self?.showAlert(title: "Failed To Get Items", message: error.localizedDescription)
            }
        })
        
    }
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        itemAlert(title: "Adding Item", message: "Enter Item Name", buttonTitle: "Add Item", item: nil)
    }
    
    @IBAction func onlineUsersPressed(_ sender: Any) {
        performSegue(withIdentifier: "OLVC", sender: nil)
    }
    
    func itemAlert(title:String,message:String, buttonTitle:String, item:Item?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField {
            (textField) in
            textField.text = item?.name
            textField.placeholder = "Item Name eg.. BasketBall"
        }
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {
            _ in
            
            let itemName = alert.textFields![0].text!
            
            if var item = item {
                // Updating Item
                item.name = itemName
                DatabaseManager.shared.updateItem(of: item.id!, with: item)
            }else{
                // Adding Item
                if let user = Auth.auth().currentUser, let email = user.email {
                    let item = Item(name: itemName, addedBy: email, completed: false)
                    DatabaseManager.shared.addItem(with: item)
                    
                }
                
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "Added By: \(item.addedBy)"
        
        if item.completed {
            cell.backgroundColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
        }else {
            cell.backgroundColor = UIColor.systemBackground
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            if item.addedBy == Auth.auth().currentUser?.email {
                DatabaseManager.shared.deleteItem(with: item.id!)
            }else {
                showAlert(title: "Delete Error", message: "Can't Delete Items You Don't Own")
            }
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = items[indexPath.row]
        if item.addedBy == Auth.auth().currentUser?.email {
            itemAlert(title: "Edit Item", message: "Enter New Item Name", buttonTitle: "Edit Item", item: item)
        }else {
            showAlert(title: "Edit Error", message: "Can't Edit Items You Don't Own")
        }
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item = items[indexPath.row]
        
        if item.addedBy == Auth.auth().currentUser?.email {
            item.completed = !item.completed
            DatabaseManager.shared.updateItem(of: item.id!, with: item)
        }else {
            showAlert(title: "Completing Error", message: "Can't Complete Item You Don't Own")
        }
    }
}

extension GroceryListViewController {
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
