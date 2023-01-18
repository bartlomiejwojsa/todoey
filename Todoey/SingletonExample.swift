//
//  SingletonExample.swift
//  Todoey
//
//  Created by Bartłomiej Wojsa on 08/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

class Car {
    var colour = "Red"
    
    static let singletonCar = Car()
}

func singletonExample() {
    let myCar = Car()
    myCar.colour = "Blue"
    
    let yourCar = Car()
    yourCar.colour = "Yellow"
    
    //using singleton
    let singletonCar = Car.singletonCar
    singletonCar.colour = "Blue"
    
    let anotherSingleton = Car.singletonCar
    print(anotherSingleton.colour)
    // prints: "Blue"
}

