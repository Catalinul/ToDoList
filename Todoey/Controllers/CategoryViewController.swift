import UIKit
import RealmSwift
import ChameleonFramework
//sursa: https://github.com/vicc/Chameleon#uicolor-methods


class CategoryViewController: SwipeTableViewController, VremeaDelegate {
    
    //try! adica daca primim exceptie aici, aplicatia va primi crash. nu ne asteptam sa primim exceptie
    let realm = try! Realm()

    var categories: Results<Category>? // ! - force unwrap; ? - optional unwrap
    
    var vremea = Vremea()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vremea.delegate = self
        
        loadCategories()
        tableView.separatorStyle = .none
        }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller nu exista.")}
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
        
        
        vremea.fetchWeather(cityName: "Bucharest")
        
    }
    
    //metode Tableview Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //daca categories nu e nil, return categories.count
                                      //daca e nil, return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) //ne folosim de cell-ul din super class
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            
            cell.backgroundColor = categoryColour
            
            //1D9BF6 = culoare default in cazul in care colour e nil
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true) //pt contrast
        }
        return cell
    }
    
    //metode Tableview Delegate
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "goToItems", sender: self)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    
    //metode Data Manipulation
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Eroare la salvarea categoriei \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // sterge date din Swipe
    
    override func updateModel(at indexPath: IndexPath)
    {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Eroare la stergerea categoriei, \(error)")}
        }
    }
    
    
    @IBAction func addButtoPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Adauga o categorie noua", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Adauga", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue() //chameleon framework, culoarea categoriei
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Adauga o noua categorie"
        }
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var temperaturaLabel: UILabel!
    
    func didUpdateWeather(_ vremea: Vremea, weather: WeatherModel){
        DispatchQueue.main.async {
            self.temperaturaLabel.text = String(format: "%@%@ °C", "Temperatura in Bucuresti: ", weather.temperatureString)
            
            self.temperaturaLabel.backgroundColor = UIColor.randomFlat()
            self.temperaturaLabel.textColor = ContrastColorOf(self.temperaturaLabel.backgroundColor!, returnFlat: true)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}


