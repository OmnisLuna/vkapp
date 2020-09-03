import RealmSwift
import UIKit

class RealmHelper {
    static let ask = RealmHelper()

    private init() {}

    func saveObjects<T: Object>(_ objects: [T]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(objects, update: .all)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func changeIsMember(_ id: Int, _ newValue: Int) {
        let realm = try! Realm()
        let groups: [GroupRealm] = Array(realm.objects(GroupRealm.self).filter("id = %@", id))
        try! realm.write {
          groups[0].isMember = newValue
        }
    }
    
    func refresh() {
        do {
            let realm = try Realm()
            realm.refresh()
        } catch {
            print(error)
        }
        
    }
    
    func deleteObjects<T: Object>(_ objects: [T]) {
        do {
            let realm = try Realm()
            try! realm.write {
                realm.delete(objects);
            }
        } catch {
            print(error)
        }
    }
    
    func getObjects<T: Object>()->[T] {
        let realm = try! Realm()
        let realmResults = realm.objects(T.self)
        return Array(realmResults)

    }
    
    func getObjects<T: Object>(filter: String)->[T] {
        let realm = try! Realm()
        let realmResults = realm.objects(T.self).filter(filter)
        return Array(realmResults)

    }
    
    func cleanRealm() {
        do {
            let realm = try Realm()
            try! realm.write {
                realm.deleteAll()
            }
        } catch {
                print(error)
        }
    }
}
