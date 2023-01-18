//
//  Category.swift
//  Todoey
//
//  Created by Bartłomiej Wojsa on 11/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "#000000"
    let items = List<Task>()
}
