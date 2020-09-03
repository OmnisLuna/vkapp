import UIKit
import SDWebImage

class RepostNewsCard: UITableViewCell {
    
    @IBOutlet weak var postOwnerAvatar: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var publishDate: UILabel!
    @IBOutlet weak var repostSourceAvatar: UIImageView!
    @IBOutlet weak var repostSourceName: UILabel!
    @IBOutlet weak var repostSourceDate: UILabel!
    @IBOutlet weak var postTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resizePostButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resizePostButton: UIButton!
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
    var textViewExpanded: Bool = false
    var postTextViewExpanded: Bool = false
    var moreText: String = "Show more"
    var lessText: String = "Show less"
    var postHeight: CGFloat = 0
    var repostHeight: CGFloat = 0
    @IBOutlet weak var cellContentView: UIView!
    
    func configure(with newsCard: NewRecord) {
        self.newsCard = newsCard
        ownerName.text = newsCard.sourceName
        
        if repostPhoto.image == nil {
            repostPhoto.isHidden = true
        } else {
            repostPhoto.isHidden = false
        }
        
        postOwnerAvatar.sd_setImage(with: URL(string: newsCard.sourceAvatar))
        repostSourceAvatar.sd_setImage(with: URL(string: newsCard.copyHistory?[0].sourceAvatar ?? ""))
        publishDate.text = newsCard.publishDate
        viewsCount.text = "\(newsCard.views?.count ?? 0)"
        likesCount.text = "\(newsCard.likes.count)"
        commentsCount.text = "\(newsCard.comments.count)"
        sharingCount.text = "\(newsCard.reposts.count)"
        
        postHeight = getRowHeightFromText(text: newsCard.text, textView: postTextView)
        repostHeight = getRowHeightFromText(text: newsCard.copyHistory?[0].text, textView: repostTextView)
        
        configureRezisableTextView(text: newsCard.copyHistory?[0].text ?? "",
                                   textView: repostTextView, textHeight: repostHeight,
                                   resizeButton: resizeTextViewButton,
                                   textViewHeightConstraint: repostTextHeightConstraint,
                                   resizeButtonHeightConstraint: resizeButtonHeightConstraint)
        
        configureRezisableTextView(text: newsCard.text,
                                   textView: postTextView, textHeight: postHeight,
                                   resizeButton: resizePostButton,
                                   textViewHeightConstraint: postTextViewHeightConstraint,
                                   resizeButtonHeightConstraint: resizePostButtonHeightConstraint)
        
        repostSourceName.text = newsCard.copyHistory?[0].sourceName
        repostSourceDate.text = newsCard.copyHistory?[0].publishDate
    }
    
    func configureRezisableTextView(text: String,
                                    textView: UITextView,
                                    textHeight: CGFloat,
                                    resizeButton: UIButton,
                                    textViewHeightConstraint: NSLayoutConstraint,
                                    resizeButtonHeightConstraint: NSLayoutConstraint) {
        
        let textHeight = getRowHeightFromText(text: text, textView: textView)
        textView.text = text
        if textHeight > 100 {
            DispatchQueue.main.async {
                resizeButtonHeightConstraint.constant = 14
                textViewHeightConstraint.constant = 100
                resizeButton.isHidden = false
                resizeButton.setTitle(self.moreText, for: .normal)
                self.layoutIfNeeded()
            }
        } else if (0 < textHeight) && (textHeight < 100) {
            resizeButtonHeightConstraint.constant = 0
            let maxWidth = self.bounds.size.width-20
            let sizeOfTextView = textView.sizeThatFits(CGSize(width: maxWidth, height: textHeight))
            DispatchQueue.main.async {
                resizeButton.isHidden = true
                textViewHeightConstraint.constant = sizeOfTextView.height
                self.layoutIfNeeded()
            }
        } else if text == "" {
            textViewHeightConstraint.constant = 0
            resizeButtonHeightConstraint.constant = 0
            textView.isHidden = true
            resizeButton.isHidden = true
        }
    }
    
    fileprivate func resizeView(textView: UITextView, height: CGFloat) {
        var newFrame = textView.frame
        let width = newFrame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width,
                                                   height: height))
        newFrame.size = CGSize(width: width, height: newSize.height)
        DispatchQueue.main.async {
            textView.frame = newFrame
        }
    }
    
    func getRowHeightFromText(text: String!, textView: UITextView) -> CGFloat {
        textView.text = text
        textView.font = UIFont(name: "Helvetica", size:  15.0)
        textView.sizeToFit()
        
        let txtFrame = textView.frame
        let sizeHeight = txtFrame.size.height
        return sizeHeight
    }
    
    func onMoreClick(status: Bool,
                     text: String,
                     textHeight: CGFloat,
                     textView: UITextView,
                     resizeButton: UIButton,
                     textViewHeightConstraint: NSLayoutConstraint) {
        
        if status == false {
            DispatchQueue.main.async {
                textViewHeightConstraint.constant = textHeight
                self.resizeView(textView: textView, height: textHeight)
                resizeButton.setTitle(self.lessText, for: .normal)
                if textView == self.postTextView {
                    self.postTextViewExpanded = true
                } else {
                    self.textViewExpanded = true
                }
                self.delegate?.reloadCell(self, needReload: true)
            }
        } else {
            if textView == self.postTextView {
                self.postTextViewExpanded = false
            } else {
                self.textViewExpanded = false
            }
            delegate?.reloadCell(self, needReload: true)
            if textHeight > 100 {
                DispatchQueue.main.async {
                    textViewHeightConstraint.constant = 100
                }
            } else {
                DispatchQueue.main.async {
                    textViewHeightConstraint.constant = textHeight
                    self.resizeView(textView: textView, height: textHeight)
                }
            }
            DispatchQueue.main.async {
                resizeButton.setTitle(self.moreText, for: .normal)
            }
            
        }
        
    }
    
    @IBAction func showMoreButtonClicked(_ sender: UIButton) {
        
        if sender == self.resizePostButton {
            onMoreClick(status: postTextViewExpanded,
                        text: newsCard?.text ?? "",
                        textHeight: postHeight,
                        textView: postTextView,
                        resizeButton: resizePostButton,
                        textViewHeightConstraint: postTextViewHeightConstraint)
            
        } else if sender == self.resizeTextViewButton {
            onMoreClick(status: textViewExpanded,
                        text: newsCard?.copyHistory?[0].text ?? "",
                        textHeight: repostHeight,
                        textView: repostTextView,
                        resizeButton: resizeTextViewButton,
                        textViewHeightConstraint: repostTextHeightConstraint)
            
        }
    }
}

protocol RepostViewCellDelegate: AnyObject {
    func reloadCell(_ cell: RepostNewsCard,
                    needReload: Bool)
}


