import Foundation
import RealmSwift

class Category:Object {
    @objc dynamic var name: String = ""
    
    //in fiecare categorie avem item-uri (relatie forward catre Item)
    // in fiecare category avem o relatie One to Many cu o lista de Item-uri
    let items = List<Item> () //sintaxa de realm, initiailiza o lista de array-uri. List e o clasa din Realm
    
    @objc dynamic var colour: String = ""
}
