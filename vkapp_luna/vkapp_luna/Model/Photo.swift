import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class PhotoRealm: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerId: Int = 0
    @objc dynamic var url: String?
    @objc dynamic var isLikedByMe: Bool = false
    @objc dynamic var likesCount: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
