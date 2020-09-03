import UIKit

class RepostNewsCard: UITableViewCell {
    
    @IBOutlet weak var postOwnerAvatar: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var publishDate: UILabel!
    //    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var repostSourceAvatar: UIImageView!
    @IBOutlet weak var repostSourceName: UILabel!
    @IBOutlet weak var repostSourceDate: UILabel!
    //    @IBOutlet weak var repostDescription: UILabel!
    @IBOutlet weak var repostPhoto: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var sharingCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var repostTextView: UITextView!
    @IBOutlet weak var repostSourceStack: UIStackView!
    @IBOutlet weak var resizeTextViewButton: UIButton!
    @IBOutlet weak var repostTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resizeButtonHeightConstraint: NSLayoutConstraint!
    var newsCard: NewRecord?
    weak var delegate: RepostViewCellDelegate?
    var textViewExpanded = false
    var moreText: String = "Show more"
    var lessText: String = "Show less"
    
    func configure(with newsCard: NewRecord) {
        self.newsCard = newsCard
        ownerName.text = newsCard.sourceName
        
        if repostPhoto.image == nil {
            repostPhoto.isHidden = true
        } else {
            repostPhoto.isHidden = false
        }
        
        publishDate.text = newsCard.publishDate
        postTextView.text = newsCard.text
        viewsCount.text = "\(newsCard.views?.count ?? 0)"
        likesCount.text = "\(newsCard.likes.count)"
        commentsCount.text = "\(newsCard.comments.count)"
        sharingCount.text = "\(newsCard.reposts.count)"
        
        let repostTextHeight = getRowHeightFromText(strText: newsCard.copyHistory?[0].text, text: repostTextView)
        
        //        print("jskfhksj \(repostTextHeight)")
        
        repostTextView.text = newsCard.copyHistory?[0].text
        
        // в зависимости от высоты, которая нужна под текст
        if repostTextHeight > 100 {
            DispatchQueue.main.async {
                self.resizeButtonHeightConstraint.constant = 14
                self.repostTextHeightConstraint.constant = 100
                self.resizeTextViewButton.isHidden = false
                self.resizeTextViewButton.setTitle(self.moreText, for: .normal)
                self.layoutIfNeeded()
            }
        } else if (0 < repostTextHeight) && (repostTextHeight < 100) {
            self.resizeButtonHeightConstraint.constant = 0
            let maxWidth = self.bounds.size.width-20
            let sizeOfLabel = self.repostTextView.sizeThatFits(CGSize(width: maxWidth, height: repostTextHeight))
            DispatchQueue.main.async {
                self.resizeTextViewButton.isHidden = true
                self.repostTextHeightConstraint.constant = sizeOfLabel.height
                self.layoutIfNeeded()
            }
        } else {
            repostTextHeightConstraint.constant = 0
            self.resizeButtonHeightConstraint.constant = 0
            repostTextView.isHidden = true
            self.resizeTextViewButton.isHidden = true
        }
        
        repostSourceName.text = newsCard.copyHistory?[0].sourceName
        repostSourceDate.text = newsCard.copyHistory?[0].publishDate
    }
    
    fileprivate func resizeView(textView: UITextView) {
        var newFrame = textView.frame
        let width = newFrame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: width, height: newSize.height)
        DispatchQueue.main.async {
            textView.frame = newFrame
        }
    }
    
    fileprivate func resizeViewMin(textView: UITextView) {
        var newFrame = textView.frame
        let width = newFrame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width,
                                                   height: CGFloat.leastNonzeroMagnitude))
        newFrame.size = CGSize(width: width, height: newSize.height)
        textView.frame = newFrame
    }
    
    func getRowHeightFromText(strText : String!, text: UITextView) -> CGFloat {
        text.text = strText
        text.font = UIFont(name: "Helvetica", size:  17.0)
        text.sizeToFit()
        
        let txtFrame = text.frame
        let sizeHeight = txtFrame.size.height
        return sizeHeight
    }
    
    @IBAction func showMoreButtonClicked(_ sender: UIButton) {
        let height = self.getRowHeightFromText(strText: newsCard?.copyHistory?[0].text, text: repostTextView)
        
        
        if textViewExpanded == false {
            DispatchQueue.main.async {
                self.repostTextHeightConstraint.constant = height
                self.resizeTextViewButton.setTitle(self.lessText, for: .normal)
                self.textViewExpanded = true
                self.delegate?.reloadCell(self, needReload: true)
            }
        } else {
            textViewExpanded = false
            delegate?.reloadCell(self, needReload: true)
            if height > 100 {
                DispatchQueue.main.async {
                    self.repostTextHeightConstraint.constant = 100
                }
            } else {
                DispatchQueue.main.async {
                    self.repostTextHeightConstraint.constant = height
                }
            }
            DispatchQueue.main.async {
                self.resizeTextViewButton.setTitle(self.moreText, for: .normal)
            }
            
        }
    }
}

protocol RepostViewCellDelegate: AnyObject {
    func reloadCell(_ cell: RepostNewsCard,
                    needReload: Bool)
}


