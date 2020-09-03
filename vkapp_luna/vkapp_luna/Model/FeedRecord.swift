
import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class FeedRecord {

    var id: Int = 0
    var sourceId: Int = 0
    var publishDate: Int = 0
    var type: String = ""
    var text: String = ""
    var isLikedByMe: Bool = false
    var likesCount: Int = 0
    var commentsCount: Int = 0
    var reportsCount: Int = 0
    var viewsCount: Int = 0
    var sourceAvatar: String?
    var sourceName: String?
//    var attachments: [Attachments?]
    var photo: String? = ""
//    var copyHistory: [CopyHistory?]

    init(json: JSON) {
        self.id = json["post_id"].intValue
        self.sourceId = json["source_id"].intValue
        self.publishDate = json["date"].intValue
        self.type = json["type"].stringValue
        self.text = json["text"].stringValue
        self.isLikedByMe = json["likes"]["user_likes"].boolValue
        self.likesCount = json["likes"]["count"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.reportsCount = json["reposts"]["count"].intValue
        self.viewsCount = json["views"]["count"].intValue
        self.photo = json["attachments"][0]["photo"]["sizes"][0]["url"].stringValue
//        self.copyHistory = json["copy_history"].arrayObject ?? []
    }
}
//
////class Likes: Codable {
////    var isLikedByMe: Bool = false
////    var likesCount: Int = 0
////
////    enum CodingKeys: String, CodingKey {
////        case isLikedByMe = "user_likes"
////        case count = "count"
////    }
////
////}
//
//class Size: Decodable {
//    var url: String
//    var height: Int
//    var width: Int
//}
//
////class Photo: Codable {
////   var id: Int
////    var sizes: [Size]
////}
//
//extension Photo {
//    enum CodingKeys: String, CodingKey {
//    case id = "id"
//    case sizes = "sizes"
//    }
//}
//
//struct Attachments: Codable {
//    var type: String
//    var photo: Photo
//}
//
//extension Attachments {
//    enum CodingKeys: String, CodingKey {
//    case type = "type"
//    case photo = "photo"
//    }
//}
//
//
//struct CopyHistory: Codable {
//       var id: Int
//       var ownerId: Int
//       var fromId: Int
//       var publishDate: Int
//       var postType: String
//       var text: String
//       var attachments: [Attachments]?
//}
//
//extension CopyHistory {
//    enum CodingKeys: String, CodingKey {
//        case id = "post_id"
//        case ownerId = "owner_id"
//        case fromId = "from_id"
//        case publishDate = "date"
//        case postType = "post_type"
//        case text = "text"
//        case attachments = "attachments"
//    }
//}
//
//
////
////class CopyHistory {
////    var id: Int = 0
////    var ownerId: Int = 0
////    var fromId: Int = 0
////    var publishDate: Int = 0
////    var postType: String = ""
////    var text: String = ""
////    var attachments: [Attachments]?
////
////    init(json: JSON) {
////        self.id = json["post_id"].intValue
////        self.ownerId = json["owner_id"].intValue
////        self.fromId = json["from_id"].intValue
////        self.publishDate = json["date"].intValue
////        self.postType = json["post_type"].stringValue
////        self.text = json["text"].stringValue
////    }
////}
//
////enum PostAttachmentsType {
////    case attachments(Attachments)
////    case copyHistory(CopyHistory)
////    case unknown
////
////    var attachments: Attachments? {
////        guard case let .attachments(value) = self else { return nil }
////        return value
////    }
////
////    var copyHistory: CopyHistory? {
////        guard case let .copyHistory(value) = self else { return nil }
////        return value
////    }
//}


class SourceDetails {
        var id: Int = 0
        var name: String = ""
        var avatar: String = ""
}
