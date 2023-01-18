//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    @IBOutlet var searchBtn: UISearchBar!
    
    var tasks: Results<Task>?
    
    var selectedCategory : Category? {
        didSet {
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedColor = selectedCategory?.color, let themeColor = UIColor(hexString: selectedColor) {
            if let navBar = navigationController?.navigationBar {
                navBar.backgroundColor = themeColor
                navBar.tintColor = ContrastColorOf(themeColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(themeColor, returnFlat: true)]
//                let navBarAppearance = UINavigationBarAppearance()
//                navBar.standardAppearance = navBarAppearance
//                navBar.scrollEdgeAppearance = navBarAppearance
            }
            title = selectedCategory?.name ?? "Tasks"
            
            searchBtn.barTintColor = themeColor
            searchBtn.searchTextField.textColor = ContrastColorOf(themeColor, returnFlat: true)
            searchBtn.searchTextField.tintColor = ContrastColorOf(themeColor, returnFlat: true)
            searchBtn.searchTextField.backgroundColor = themeColor
            
            searchBtn.searchTextField.leftView?.tintColor = ContrastColorOf(themeColor, returnFlat: true)
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .search, state: .normal)
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var cellText = "No tasks yet"
        var accessoryType: UITableViewCell.AccessoryType = .none
        if let task = tasks?[indexPath.row] {
            cellText = task.title
            accessoryType = task.done ? .checkmark : .none
            let computedCGFloat = CGFloat(indexPath.row) / CGFloat(tasks?.count ?? 1)
            if let color = UIColor(hexString: (selectedCategory?.color ?? "#000000"))?.darken(byPercentage: computedCGFloat) {
                cell.backgroundColor = color.withAlphaComponent(0.7)
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        }
        cell.textLabel?.text = cellText
        cell.accessoryType = accessoryType
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = tasks?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error while updating item", error)
            }
            
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Add new items
    

    @IBAction func addNewItemButton(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let newTaskName = textField.text, !newTaskName.isEmpty, let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newTask = Task()
                        newTask.title = newTaskName
                        newTask.done = false
                        newTask.createdDate = Date().timeIntervalSince1970
                        currentCategory.items.append(newTask)
                    }
                } catch {
                    print("Error while saving item", error)
                }
                DispatchQueue.main.async {
                    self.searchBtn.text = ""
                    self.searchBtn.resignFirstResponder()
                    self.refresh()
                    self.tableView.reloadData()
                }
                
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    func save(task: Task) {
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error saving new task, \(error)")
        }
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        //handle action by updating model with deletion
        print("Im gonna delete this task!")
        if let cellTask = self.tasks?[indexPath.row] {
            self.remove(task: cellTask)

        }
    }
    
    func remove(task: Task) {
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Error saving new task, \(error)")
        }
    }
    
    func refresh() {
        tasks = selectedCategory?.items.sorted(byKeyPath: "createdDate", ascending: false)
        tableView.reloadData()
    }
    
}

//MARK: - SearchBar delegate methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //[c] case insensitive: lowercase & uppercase values are treated the same
        //[d] diacritic insensitive: special characters treated as the base character
        tasks = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate", ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            refresh()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
