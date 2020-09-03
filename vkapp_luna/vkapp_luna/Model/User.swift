//
//  UserProfile.swift
//  nvleonovich_homework
//
//  Created by nvleonovich on 01.04.2020.
//  Copyright © 2020 nvleonovich. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

struct User {
    var id: Int
    var name: String
    var surname: String
    var avatar: String?

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["first_name"].stringValue
        self.surname = json["last_name"].stringValue
        self.avatar = json["photo_400"].stringValue
    }
}

class UserRealm: Object, Decodable {
    @objc dynamic var id: Int
    @objc dynamic var name: String
    @objc dynamic var surname: String
    @objc dynamic var avatar: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension UserRealm {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "first_name"
        case surname = "last_name"
        case avatar = "photo_100"
    }
}

struct UserRealmResponse: Decodable {
    let response: UserRealmItems
}

struct UserRealmItems: Decodable {
    let items: [UserRealm]
}
