//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bartłomiej Wojsa on 09/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("ViewDidLoad")
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            let themeColor = FlatSkyBlue()
            navBar.backgroundColor = themeColor
            navBar.tintColor = ContrastColorOf(themeColor, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(themeColor, returnFlat: true)]
//            let navBarAppearance = UINavigationBarAppearance()
//            navBar.standardAppearance = navBarAppearance
//            navBar.scrollEdgeAppearance = navBarAppearance
        }

    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name your new category..."
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newCategoryName = textField.text, !newCategoryName.isEmpty {
                let newCategory = Category()
                newCategory.name = newCategoryName
                newCategory.color = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
                self.tableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let existingCategory = categories?[indexPath.row] {
            cell.textLabel?.text = existingCategory.name
            cell.accessoryType = .disclosureIndicator
            if let hexUIColor = UIColor(hexString: existingCategory.color) {
                cell.backgroundColor = hexUIColor.withAlphaComponent(0.8)
                cell.textLabel?.textColor = ContrastColorOf(hexUIColor, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No categories added yet"
        }
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard let safeCellAccessoryType = cell?.accessoryType else {
            return
        }
        if safeCellAccessoryType == .disclosureIndicator {
            performSegue(withIdentifier: "goToTasks", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTasks" {
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow, let safeCategory = categories?[indexPath.row] {
                destinationVC.selectedCategory = safeCategory
            }
            // some extra modifications
        }
    }
    
    //MARK: - Data manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving new category, \(error)")
        }
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        //handle action by updating model with deletion
        print("Im gonna delete this category!")
        if let cellCategory = self.categories?[indexPath.row] {
            self.remove(category: cellCategory)

        }
    }
    
    func remove(category: Category) {
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print("Error deleting category \(error)")
        }
    }
    
}
