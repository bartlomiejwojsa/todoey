//
//  Data.swift
//  Todoey
//
//  Created by Bartłomiej Wojsa on 11/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
