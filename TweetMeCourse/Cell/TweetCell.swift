//
//  TweetCell.swift
//  TweetMeCourse
//
//  Created by Admin on 19.05.2021.
//

import UIKit

class TweetCell: UICollectionViewCell {
    weak var delegate: TweetCellDelegate?
    var userID: String?
    var tweetID: String?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48/2
        imageView.backgroundColor = .white
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let infoLabel: UILabel = UILabel()
    var likeButton = UIButton()
    var retweetButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "SecondaryColor")
        addSubview(profileImageView)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
        profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
        profileImageView.heightAnchor.constraint(equalToConstant: 48),
        profileImageView.widthAnchor.constraint(equalToConstant: 48)])
        
        let stack = UIStackView(arrangedSubviews: [infoLabel, textLabel])
        addSubview(stack)
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 5
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: profileImageView.topAnchor),
        stack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
        stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)])
        
        self.layer.cornerRadius = 20
        
        textLabel.textColor = UIColor(named: "PrimaryColor")
        
        let actionStack = UIStackView(arrangedSubviews: [likeButton, retweetButton])
        actionStack.distribution = .equalCentering
        actionStack.axis = .horizontal
        actionStack.spacing = 30
        addSubview(actionStack)
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            actionStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            actionStack.centerXAnchor.constraint(equalTo: centerXAnchor)])
    
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        likeButton.addGestureRecognizer(likeTap)
        
        let retweetTap = UITapGestureRecognizer(target: self, action: #selector(retweetButtonTapped))
        retweetButton.addGestureRecognizer(retweetTap)
    }
    func setInfoLabel(name: String, screenName: String, verified: Bool = false) {
        
        
        let fullString = NSMutableAttributedString(string:"\(name) ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(named: "PrimaryColor")!])
        if (verified) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "checkmark")
            fullString.append(NSAttributedString(attachment: imageAttachment))
        }
        fullString.append(NSAttributedString(string: " @\(screenName)", attributes: [.font:            UIFont.systemFont(ofSize: 14),
             .foregroundColor: UIColor.lightGray]))
        
        infoLabel.attributedText = fullString
    }
    
    func setTweetText(text: String) {
        textLabel.text = text
        print(textLabel.frame.width)
    }
    
    func setLike(_ isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func setRetweeted(_ isRetweeted: Bool) {
        if !isRetweeted {
            retweetButton.setImage(UIImage(systemName: "arrow.2.squarepath"), for: .normal)
        }
        else {
            retweetButton.isHidden = true
        }
    }
    
    @objc func likeButtonTapped() {
        delegate?.likeButtonTapped(tweetID: tweetID, sender: self)
            
    }
    
    @objc func retweetButtonTapped(){
        delegate?.retweetButtonTapped(tweetID: tweetID, sender: self)
    }
    
    @objc func userImageTapped(){
        delegate?.userImageTapped(userID: userID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


protocol TweetCellDelegate: AnyObject {
    func userImageTapped(userID: String?)
    func retweetButtonTapped(tweetID: String?, sender: TweetCell)
    func likeButtonTapped(tweetID: String?, sender: TweetCell)
}