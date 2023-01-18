//
//  Task.swift
//  Todoey
//
//  Created by Bartłomiej Wojsa on 11/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdDate: Double = 0
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
