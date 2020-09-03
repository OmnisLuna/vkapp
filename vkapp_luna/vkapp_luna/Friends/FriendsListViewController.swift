import UIKit
import RealmSwift

class FriendsListViewController: UITableViewController {
    
    @IBOutlet var tableFriendsView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var users = [UserRealm]()
    private var sectionTitles = [String]()
    var token: NotificationToken?
    private var imageService: ImageService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableFriendsView.dataSource = self
        searchBar.delegate = self
        requestData()
        imageService = ImageService(container: tableView)
    }
    
    //friends table sections
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //friends table rows
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Friend", for: indexPath) as! FriendTableViewCell
        
        cell.myFriendName.text = "\(getFullName(users[indexPath.row].name, users[indexPath.row].surname))"
        cell.myFriendAvatar.image = imageService?.photo(atIndexpath: indexPath, byUrl: users[indexPath.row].avatar ?? "Portrait_Placeholder.png")
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getFriendPhotos" {
            guard let target = segue.destination as? FriendsPhotoCollectionViewController,
                let selectedIndexPath = tableView.indexPathForSelectedRow else {
                    return
            }
            target.currentUserId = users[selectedIndexPath.row].id
        }
    }
    
    private func getFullName(_ name: String, _ surname: String) -> String {
        let fullName = "\(name) " + "\(surname)"
        return fullName
    }
    
    private func requestData() {
        Requests.go.getMyFriends { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print(error)
            }
            self?.tableView.reloadData()
        }
    }
    
    private func notificationsObserver() {
        guard let realm = try? Realm() else { return }
        token = realm.objects(UserRealm.self).observe({ [weak self] (result) in
            switch result {
            case .initial:
                print("My friends data initialized")
            case .update(_, deletions: _, insertions: _, modifications: _):
                print("My friends data changed")
                self?.tableView.reloadData()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
}

extension FriendsListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let sortedUsers: [UserRealm] = RealmHelper.ask.getObjects()
        
        users = searchText.isEmpty ? sortedUsers : users.filter { (user: UserRealm) -> Bool in
            return getFullName(user.name, user.surname)
                .range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
}
