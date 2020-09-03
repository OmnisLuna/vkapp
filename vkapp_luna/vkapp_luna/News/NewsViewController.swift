import UIKit

class NewsViewController: UITableViewController {
    
    private var myNews = Array<NewRecord>()
    private var startFrom: String = ""
    private var imageService: ImageService?
    let queueGroup = DispatchGroup()
    var isLoading = false
    var width: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        tableView.dataSource = self
        width = tableView.bounds.width - 20
        requestData()
        imageService = ImageService(container: tableView)
        setupRefreshControl()
        tableView.prefetchDataSource = self
        
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
    }
    
    @objc func refreshNews() {
        self.refreshControl?.beginRefreshing()
        let mostFreshNewsDate = self.myNews.first?.date ?? Int(Date().timeIntervalSince1970)
        Requests.go.getNews(startTime: (mostFreshNewsDate + 1)) { [weak self] result, nextFrom in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            switch result {
            case .success(let news):
                guard news.items.count > 0 else { return }
                self.myNews.insert(contentsOf: news.items, at: 0)
                var indexPathes : [IndexPath] = []
                for i in 0..<(news.items.count) {
                    indexPathes.append(IndexPath(row: i, section: 0))
                }
                self.queueGroup.notify(queue: DispatchQueue.main) {
                    self.tableView.insertRows(at: indexPathes, with: .automatic)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    private func requestData() {
        Requests.go.getNews() { [weak self] result, nextFrom in
            guard let self = self else { return }
            self.isLoading = true
            switch result {
            case .success(let news):
                self.myNews = news.items
                self.isLoading = false
                self.startFrom = news.nextFrom
            case .failure(let error):
                self.isLoading = false
                print(error)
            }
            self.queueGroup.notify(queue: DispatchQueue.main) {
                self.tableView.reloadData()
            }
        }
    }
    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCard = myNews[indexPath.row]
        if newsCard.type == "post" && newsCard.copyHistory == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCard", for: indexPath) as! NewsCard
            
            let ph = newsCard.attachments?[0].photo?.sizes[3]
            cell.postPhoto.image = imageService?.photo(atIndexpath: indexPath, byUrl: ph?.url ?? "")
            let aspectRatio = (ph?.aspectRatio ?? 0)
            let height = width * aspectRatio
            
            cell.postPhoto.sizeThatFits(CGSize(width: width, height: height))
            cell.configure(with: newsCard)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepostNewsCard", for: indexPath) as! RepostNewsCard
            
    //        if cell.delegate == nil {
    //            cell.delegate = self
    //        }
            
            let ph = newsCard.copyHistory?[0].attachments?[0].photo?.sizes[3]
            cell.repostPhoto.image = imageService?.photo(atIndexpath: indexPath, byUrl: ph?.url ?? "")
            let aspectRatio = (ph?.aspectRatio ?? 0)
            let height = width * aspectRatio
            
            cell.repostPhoto.sizeThatFits(CGSize(width: width, height: height))

            cell.configure(with: newsCard)
            return cell
        }
    }
    //
    
    //
    //        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //
    //            let tableWidth = tableView.bounds.width
    //            let news = self.myNews[indexPath.row].
    //            let aspectRatio = (news.copyHistory?[0].attachments?[0].photo?.sizes[1].aspectRatio)!
    //            let cellHeight = tableWidth * aspectRatio
    //            return cellHeight
    //
    //        }
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    //
    //    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
}

extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let max = indexPaths.map({ $0.row }).max() else { return }
        if max > (myNews.count - 5) {
            
            if !isLoading {
                isLoading = true
                Requests.go.getNews(startFrom: startFrom) { [weak self] result, nextFrom in
                    guard let self = self else { return }
                    switch result {
                    case .success(let news):
                        guard news.items.count > 0 else { return }
                        let oldIndex = self.myNews.count
                        self.myNews.insert(contentsOf: news.items, at: oldIndex-1)
                        self.startFrom = news.nextFrom
                        
                        var indexPathes : [IndexPath] = []
                        for i in oldIndex..<(self.myNews.count){
                            indexPathes.append(IndexPath(row: i, section: 0))
                        }
                        self.tableView.insertRows(at: indexPathes, with: .automatic)
                        self.isLoading = false
                    case .failure(let error):
                        self.isLoading = false
                        print(error)
                    }
                }
            }
        }
    }
}

extension NewsViewController: RepostViewCellDelegate {
    func reloadCell(_ cell: RepostNewsCard, needReload: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
//        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath],
                             with: .automatic)
//        tableView.endUpdates()
    }
}
