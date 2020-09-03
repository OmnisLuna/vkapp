import UIKit
import SDWebImage
import RealmSwift
import PromiseKit

class GroupsListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableGroupsView: UITableView!
    
    var myGroups = [GroupRealm]()
    var token: NotificationToken?
    private var imageService: ImageService?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableGroupsView.dataSource = self
        searchBar.delegate = self
        requestData()
        notificationsObserver()
        imageService = ImageService(container: tableView)
        }
    
    private func notificationsObserver() {
        guard let realm = try? Realm() else { return }
        token = realm.objects(GroupRealm.self).observe({ [weak self] (result) in
            switch result {
            case .initial:
                print("My groups data initialized")
            case .update(_, deletions: _, insertions: _, modifications: _):
                print("My groups data changed")
                self?.tableView.reloadData()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        requestData()
        RealmHelper.ask.refresh()
    }
    
    private func requestData() {
        RequestsPromise.go.getMyGroupsPromise().get { [weak self] groups in
            guard let self = self else {
                return
            }
            RealmHelper.ask.saveObjects(groups)
            self.myGroups = RealmHelper.ask.getObjects(filter: "isMember == 1")
            self.myGroups.sort{ $0.name < $1.name }
            
        }.done(on: .main) { [weak self] _ in
            guard self != nil else {
                return
            }
            self?.tableView.reloadData()
        }.catch { error in
            print(error)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupCell", for: indexPath) as! MyGroupTableViewCell
        
        cell.name.text = myGroups[indexPath.row].name
        cell.avatar.image = imageService?.photo(atIndexpath: indexPath, byUrl: myGroups[indexPath.row].avatar ?? "placeholder-1-300x200.png")
        
        return cell
    }
    
    @IBAction func openGroups(_ sender: Any) {
        let destination = GroupsSearchTableViewController()
        destination.requestData()
        RealmHelper.ask.refresh()
    }
    
    @IBAction func addGroup(segue: UIStoryboardSegue) {
        
        if segue.identifier == "AddGroup" {
            let allGroupsController = segue.source as! GroupsSearchTableViewController
            if let indexPath = allGroupsController.tableView.indexPathForSelectedRow {
                let group = allGroupsController.allGroups[indexPath.row].id
                Requests.go.joinGroup(id: group)
                RealmHelper.ask.changeIsMember(group, 1)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let group = myGroups[indexPath.row].id
            Requests.go.leaveGroup(id: group)
            DispatchQueue.main.async {
                self.myGroups.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            RealmHelper.ask.changeIsMember(group, 0)
            }
        }
    }
}

extension GroupsListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var sortedGroups: [GroupRealm] = RealmHelper.ask.getObjects(filter: "isMember == 1")
        sortedGroups.sort{ $0.name < $1.name }
        myGroups = searchText.isEmpty ? sortedGroups : myGroups.filter { (group: GroupRealm) -> Bool in
            return group.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
}
