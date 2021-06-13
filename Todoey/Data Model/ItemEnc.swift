import Foundation

// trebuie specificat Encodable ca sa putem encoda datele intr-un .json sau .plist
// nu putem sa avem clase custom drept tipuri de date in clasele Encodable
// la fel trb sa facem si cu Decodable
//cuvantul echivalent este Codable
class ItemEnc: Encodable, Decodable{
    
    var title: String = ""
    var done: Bool = false
}
