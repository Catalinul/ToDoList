import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    //inverse relationshiop catre Category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    @objc dynamic var dateCreated: Date?
}
