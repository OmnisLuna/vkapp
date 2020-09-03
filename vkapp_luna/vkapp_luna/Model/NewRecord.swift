import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift


struct NewsListResponse: Decodable {
    let response: NewsList
}

class NewRecord: Decodable {
    var postId: Int
    var sourceId: Int
    var date: Int
    
    var publishDate: String {
        DateConverter.get.convertDate(date)
    }
    var type: String
    var text: String
    
    var likes: Likes
    var comments: Comments
    var reposts: Reposts
    var views: Views?
    
    var sourceUser: Profile?
    var sourceGroup: Group?
    
    var sourceName: String {
        if let profile = sourceUser {
            return "\(profile.firstName) \(profile.lastName)"
        } else if let group = sourceGroup {
            return group.name
        } else {
            return ""
        }
    }
    var sourceAvatar: String {
        if let profile = sourceUser {
            return profile.photo400 ?? ""
        } else if let group = sourceGroup {
            return group.photo200 ?? ""
        } else {
            return ""
        }
    }
    
    var attachments: [Attachments]?
    var copyHistory: [CopyHistory]?
    
    class CopyHistory: Decodable {
        var id: Int
        var ownerId: Int
        var sourceId: Int? {
            return abs(ownerId)
        }
        var fromId: Int
        var date: Int
        var publishDate: String {
            DateConverter.get.convertDate(date)
        }
        var postType: String
        var text: String
        var attachments: [AttachmentsRepost]?
        
        var sourceUser: Profile?
        var sourceGroup: Group?
        
        var sourceName: String
        {
            if let profile = sourceUser {
                return "\(profile.firstName) \(profile.lastName)"
            } else if let group = sourceGroup {
                return group.name
            } else {
                return ""
            }
        }
        var sourceAvatar: String
        {
            if let profile = sourceUser {
                return profile.photo400 ?? ""
            } else if let group = sourceGroup {
                return group.photo200 ?? ""
            } else {
                return ""
            }
        }
        
        struct AttachmentsRepost: Decodable {
            var type: String
            var photo: Photo?
            
            struct Photo: Codable {
                let id: Int
                let sizes: [Sizes]
                
                struct Sizes: Codable {
                    let height: Int
                    let url: String
                    let width: Int
                    var heightCG: CGFloat {
                        return CGFloat(height)
                    }
                    var widhtCG: CGFloat {
                        return CGFloat(width)
                    }
                    var aspectRatio: CGFloat { return CGFloat(height)/CGFloat(width) }
                }
            }
        }
    }
    
    struct Attachments: Decodable {
        var type: String
        var photo: Photo?
        var video: Video?
        
        struct Photo: Codable {
            let id: Int
            let sizes: [Sizes]
        }
        
        struct Sizes: Codable {
            let height: Int
            let url: String
            let width: Int
            
            var heightCG: CGFloat {
                return CGFloat(height)
            }
            var widhtCG: CGFloat {
                return CGFloat(width)
            }
            var aspectRatio: CGFloat { return CGFloat(height)/CGFloat(width) }
        }
        
        struct Video: Codable {
            let id: Int
            let image: [Sizes]
        }
    }
}

struct NewsList: Decodable {
    var items: [NewRecord]
    var profiles: [Profile]
    var groups: [Group]
    let nextFrom: String
}

struct Profile: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo400: String?
}

struct Group: Codable {
    let id: Int
    let name: String
    let photo200: String?
}

struct Likes: Decodable {
    let userLikes: Int
    let count: Int
}

struct Comments: Decodable {
    let count: Int
}

struct Reposts: Decodable {
    let count: Int
}

struct Views: Decodable {
    let count: Int
}
