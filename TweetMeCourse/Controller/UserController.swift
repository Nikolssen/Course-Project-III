//
//  UserController.swift
//  TweetMeCourse
//
//  Created by Admin on 20.05.2021.
//

import UIKit
import Swifter

class UserController: UIViewController {


    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var followersButton: UIButton!
    
    @IBOutlet weak var followsButton: UIButton!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: ExtendedUser?
    let userTag: UserTag
    var userTweets: [Tweet] = []
    var requestSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = 90/2
        userProfileImageView.backgroundColor = .white
        collectionView?.register(TweetCell.self, forCellWithReuseIdentifier: "TweetCellID")
        guard let swifter = TwitterService.swifter else {return}
        swifter.showUser(userTag, success: {[weak self]
            json in
            self?.user = ExtendedUser(json: json)
                if let user = self?.user
                {
                    self?.set(name: user.name, verified: user.verified)
                    self?.screenNameLabel.text = "@\(user.screenName)"
                    self?.navigationController?.navigationItem.title = "@\(user.screenName)"
                    TwitterService.imageDownloader.loadImage(for: user.userPhotoLink, completion: {image in
                        DispatchQueue.main.async {
                            self?.userProfileImageView.image = image
                        }
                    })
                    self?.followersButton.titleLabel?.text = "Followers: \(self?.user?.followersCount ?? 0)"
                    print(json)
                }
        })
        
        requestSend = true
        swifter.getTimeline(for: userTag, success: {
            json in
            if let array = json.array {
                self.userTweets.append(contentsOf: Tweet.array(of: array))
                self.collectionView.reloadData()
                self.requestSend = false
        }
        }, failure: {
            _ in
            self.requestSend = false
        })
    }

    func configureUI(){
        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        collectionView?.backgroundColor = UIColor(named: "BackgroundColor")
        followsButton.layer.cornerRadius = 30/2
        followersButton.layer.cornerRadius = 30/2
        followButton.layer.cornerRadius = 30/2
    
    }
    
    init(userID: String, nibName: String?, bundle: Bundle?) {
        userTag = .id(userID)
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(name: String, verified: Bool) {
        if verified {
            let fullString = NSMutableAttributedString(string:"\(name) ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(named: "PrimaryColor")!])
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "checkmark")
                fullString.append(NSAttributedString(attachment: imageAttachment))
            userNameLabel.attributedText = fullString
        }
        else {
            userNameLabel.text = "\(name)"
        }
    }
    @IBAction func showFollowersAction(_ sender: Any) {
        let userListVC = UserListController(userTag: userTag, option: .followers)
        navigationController?.pushViewController(userListVC, animated: true)
    }
    @IBAction func showFollowingAction(_ sender: Any) {
        let userListVC = UserListController(userTag: userTag, option: .following)
        navigationController?.pushViewController(userListVC, animated: true)
    }
    
    @IBAction func followAction(_ sender: Any) {
        if let user = user, user.following {
        }
    }
}

extension UserController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userTweets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TweetCellID", for: indexPath) as! TweetCell
        let tweet = userTweets[indexPath.item]
        cell.setInfoLabel(name: tweet.user.name, screenName: tweet.user.screenName, verified: tweet.user.verified)
        cell.setTweetText(text: tweet.text)
        cell.setLike(tweet.favorited)
        cell.setRetweeted(tweet.retweeted)
        cell.delegate = self
        cell.userID = tweet.user.id
        cell.tweetID = tweet.tweetID
        cell.profileImageView.image = UIImage(named: "UserIcon")
        TwitterService.imageDownloader.loadImage(for: tweet.user.userPhotoLink){
            image in
            DispatchQueue.main.async {
                cell.profileImageView.image = image
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
            guard let swifter = TwitterService.swifter, userTweets.count > 0, !requestSend else
            {return}
            requestSend = true
            swifter.getTimeline(for: userTag, count: 10, sinceID: userTweets.last?.tweetID, success: {
                [weak self] json in
                if var array = json.array {
                    array.remove(at: 0)
                    self?.userTweets.append(contentsOf: Tweet.array(of: array))
                    self?.collectionView.reloadData()
                    self?.requestSend = false
                }
            }, failure: {[weak self] _ in self?.requestSend = false})
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        let measureLabel = UILabel()
        measureLabel.text = userTweets[indexPath.item].text
        measureLabel.numberOfLines = 0
        measureLabel.font = UIFont.systemFont(ofSize: 14)
        measureLabel.lineBreakMode = .byCharWrapping
        measureLabel.translatesAutoresizingMaskIntoConstraints = false
        measureLabel.widthAnchor.constraint(equalToConstant: (width - 80)).isActive = true
        let height = measureLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 70
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)
    }
    
    
}

extension UserController: TweetCellDelegate{
    func userImageTapped(userID: String?) {
    }
    
    func retweetButtonTapped(tweetID: String?, sender: TweetCell) {
        
    }
    
    func likeButtonTapped(tweetID: String?, sender: TweetCell) {
        
    }
    
    
}
