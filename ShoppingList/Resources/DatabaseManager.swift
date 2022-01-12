//
//  DatabaseManager.swift
//  ShoppingList
//
//  Created by Mohammad Al-haddad on 12/01/2022.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    
    // MARK: Adding Items/Deleting/Editing
    public func addItem(with item:Item) {
        database.child("shoppingItems").child(UUID().uuidString).setValue(item.toAnyObject())
    }
    
    public func updateItem(of id:String,with item:Item){
        database.child("shoppingItems").child(id).setValue(item.toAnyObject())
    }
    
    public func deleteItem(with id:String){
        database.child("shoppingItems").child(id).removeValue()
    }
    
    public func getItems(completion: @escaping (Result<[Item],Error>) -> Void) {
        database.child("shoppingItems").queryOrdered(byChild: "name").observe(.value, with: {
            snapshot in
            
            var newItems = [Item]()
            for children in snapshot.children {
                guard let child = children as? DataSnapshot, let item = child.value as? [String:Any], let name = item["name"] as? String, let addedBy = item["addedBy"] as? String, let completed = item["completed"] as? Bool else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                newItems.append(Item(id: child.key, name: name, addedBy: addedBy, completed: completed))
            }
            
            completion(.success(newItems))
            
        })
    }
    
    
    // MARK: Online Monitor
    
    public func insertUser(of email:String){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        database.child("online").child(currentUser.uid).setValue(email)
    }
    
    
    public func removeUser(){
        guard let currentUser = Auth.auth().currentUser else {
            print("something")
            return
        }
        database.child("online").child(currentUser.uid).removeValue()
    }
    
    public func getOnlineUsers(completion: @escaping (Result<[User],Error>) -> Void){
        database.child("online").observe(.value, with: {
            snapshot in
            
            var users : [User] = []
            for children in snapshot.children {
                guard let child = children as? DataSnapshot, let email = child.value as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                users.append(User(id: child.key, email: email))
            }
            
            completion(.success(users))
            
        })
    }
    
    
    public enum DatabaseError : Error {
        case failedToFetch
    }
}
