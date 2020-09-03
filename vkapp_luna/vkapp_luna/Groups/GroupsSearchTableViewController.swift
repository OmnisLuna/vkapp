import UIKit
import SDWebImage
import RealmSwift

class GroupsSearchTableViewController: UITableViewController {
    
    @IBOutlet weak var tableAllGroupsView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var allGroups = [GroupRealm]()
    let realm = try! Realm()
    var token: NotificationToken?
    private var imageService: ImageService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableAllGroupsView.dataSource = self
        searchBar.delegate = self
        requestData()
        notificationsObserver()
        imageService = ImageService(container: tableView)
    }
    
    func requestData() {
        Requests.go.getGroupsCatalog { [weak self] result in
            switch result {
            case .success(var groups):
               groups = RealmHelper.ask.getObjects(filter: "isMember == 0")
                groups.sort{ $0.name < $1.name }
                self?.allGroups = groups
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func notificationsObserver() {
        guard let realm = try? Realm() else { return }
        token = realm.objects(GroupRealm.self).observe({ [weak self] (result) in
            switch result {
            case .initial:
                print("All groups data initialized")
            case .update(_, deletions: _, insertions: _, modifications: _):
                print("All groups data changed")
                self?.tableView.reloadData()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllGroupCell", for: indexPath) as! GroupTableViewCell
        
        cell.myGroupName.text = allGroups[indexPath.row].name
        cell.myGroupAvatar.image = imageService?.photo(atIndexpath: indexPath, byUrl: allGroups[indexPath.row].avatar ?? "placeholder-1-300x200.png")
        return cell
    }
}

extension GroupsSearchTableViewController: UISearchBarDelegate {
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var sortedGroups: [GroupRealm] = RealmHelper.ask.getObjects(filter: "isMember == 0")
        sortedGroups.sort{ $0.name < $1.name }
        allGroups = searchText.isEmpty ? sortedGroups : allGroups.filter { (group: GroupRealm) -> Bool in
            return group.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
}
