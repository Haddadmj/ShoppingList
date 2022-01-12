//
//  DatabaseModel.swift
//  ShoppingList
//
//  Created by Mohammad Al-haddad on 12/01/2022.
//

import Foundation

struct Item {
    var id:String?
    var name:String
    var addedBy:String
    
    func toAnyObject() -> Any {
        return [
            "name":name,
            "addedBy": addedBy
        ]
    }
}

struct User {
    var id:String
    var email:String
}
