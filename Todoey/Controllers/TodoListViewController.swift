import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>? //optional
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory : Category? {
        didSet{ //doar cand categoria e setata (nu e nil) chemama loadItems()
        loadItems()
        }
    }
        
    //ne folosim de NSCoder ca sa encodam array-ul de iteme intr-un fisier .plist pe care-l folosim pt a pastra datele
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //cream propriul .plist
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //print(dataFilePath) //aici gasim locatia fisierului .plist cu array-ul (NSUserDefaults)
        
        //hardcodare iteme array
        //let newItem3 = Item()
        //newItem3.title = "Termina proiectul la iOS"
        //itemArray.append(newItem3)
        
        //loadItems() //decoder pt date
        
        //salvam datele cand aplicatia se inchide tot, folosind UserDefaults
        //if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
        //  itemArray = items
        //}
    }
    
    //folosim functia asta pentru ca in cea de sunt sanse sa nu se incarca navigationController-ul si sa primim crash
    override func viewWillAppear (_ animated: Bool){
        
        if let colourHex = selectedCategory?.colour {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller nu exista.")}
        
            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColour
                
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                //titlul
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
                
                searchBar.barTintColor = navBarColour
                
            }
            
            
        }
    }
    
    // metode TableView Datasource
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return todoItems?.count ?? 1
        }
        
        //metoda care se ocupa cu aspectul fiecarei celule
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            if let item = todoItems?[indexPath.row] { // item-ul curent pe care lucram
            
            //setam textul unui item cu un obiect din array
            cell.textLabel?.text = item.title
            
            //gradient pe item-uri (ne folosim de culoarea categoriei curente)
                if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
             {  cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true) //contrast culoare gradient
             }
                
            //if item.done == true {
            //    cell.accessoryType = .checkmark
            //} else {
            //   cell.accessoryType = .none
            //}
                
            cell.accessoryType = item.done ? .checkmark : .none
            } else {
                cell.textLabel?.text = "Nu au fost item-uri adaugate."
            }
            return cell
        }

    // metode TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //in functia asta actualizam un item (checked / unchecked)
        //print(itemArray[indexPath.row])
        
        if let item = todoItems?[indexPath.row] //daca item-ul de la indexPath din todoItem nu e nil
        {   do {
                try realm.write {
                    //realm.delete(item) // delete
                    item.done = !item.done
                    }
                } catch { print("Eroare la salvarea statusului, \(error)") }
        }
        
        tableView.reloadData()
        
        //actualizam checkmark-ul
        //todoItems[indexPath.row].done = !todoItems[indexPath.row].done

        // salvam si forteaza tableview-ul sa faca reload la metodele de datasource, ca sa se actualizeze datele
        //saveItems()
        
        //animatie cand dam click pe item
        tableView.deselectRow(at: indexPath, animated: true)

    }

    // adaugam item-uri noi
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title : "Adauga item nou", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Adauga item", style: .default){ (action) in
            //ce se va intampla atunci cand butonul Adauga item nou e apasat
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                 } catch {
                    print("Eroare la salvarea item-urilor noi, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Adauga item nou"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // metoda pentru a salva item-urile in .plist
    //func saveItems(){
        //encoder
        //let encoder = PropertyListEncoder()
        //do {
            //let data = try encoder.encode(itemArray)
           //try data.write(to: dataFilePath!)
         //} catch {
            //print("Eroare la encodarea elementului din array, \(error)")}
        //tableView.reloadData()}
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
   
        tableView.reloadData()
        }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] //optionl chaining
        {   do {
            try realm.write {
                realm.delete(item)
            } } catch { print("Eroare la stegerea unui item, \(error)")}
        }
    }
    
}

//metode pt Search Bar

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true) //NSpredicate
        
        tableView.reloadData()
    }
    
    // ce se intampla cand dispare search bar-ul
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}



