import UIKit
import SDWebImage

class NewsCard: UITableViewCell {
    
    @IBOutlet weak var postOwnerAvatar: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var publishDate: UILabel!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var sharingCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var resizeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var postDescriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resizeButton: UIButton!
    var newsCard: NewRecord?
    var postHeight: CGFloat = 0
    var postTextViewExpanded: Bool = false
    var moreText: String = "Show more"
    var lessText: String = "Show less"
    
    func configure(with newsCard: NewRecord) {
        self.newsCard = newsCard
        ownerName.text = newsCard.sourceName
        
        postOwnerAvatar.sd_setImage(with: URL(string: newsCard.sourceAvatar))
        postDescription.text = newsCard.text
        publishDate.text = newsCard.publishDate
        viewsCount.text = "\(newsCard.views?.count ?? 0)"
        likesCount.text = "\(newsCard.likes.count)"
        commentsCount.text = "\(newsCard.comments.count)"
        sharingCount.text = "\(newsCard.reposts.count)"
        postHeight = getRowHeightFromText(text: newsCard.text, textView: postDescription)
        configureRezisableTextView(text: newsCard.text,
                                   textView: postDescription,
                                   textHeight: postHeight,
                                   resizeButton: resizeButton,
                                   textViewHeightConstraint: postDescriptionHeightConstraint,
                                   resizeButtonHeightConstraint: resizeButtonConstraint)
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
                resizeButton.setTitle(self.lessText, for: .normal)
                self.postTextViewExpanded = true
            }
        } else {
            self.postTextViewExpanded = false
            
            if textHeight > 100 {
                DispatchQueue.main.async {
                    textViewHeightConstraint.constant = 100
                }
            } else {
                DispatchQueue.main.async {
                    textViewHeightConstraint.constant = textHeight
                    
                }
            }
            DispatchQueue.main.async {
                resizeButton.setTitle(self.moreText, for: .normal)
            }
            
        }
        
    }
    
    @IBAction func showMoreButtonClicked(_ sender: UIButton) {
        onMoreClick(status: postTextViewExpanded,
                    text: newsCard?.text ?? "",
                    textHeight: postHeight,
                    textView: postDescription,
                    resizeButton: resizeButton,
                    textViewHeightConstraint: postDescriptionHeightConstraint)
    }
}
