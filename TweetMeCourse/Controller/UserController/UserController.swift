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
    
    private var user: User?
    private let userTag: UserTag
    private var userTweets: [Tweet] = []
    private var requestSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.backgroundColor = UIColor(named: "BackgroundColor")
        followsButton.layer.cornerRadius = 30/2
        followersButton.layer.cornerRadius = 30/2
        followButton.layer.cornerRadius = 30/2
        
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = 90/2
        userProfileImageView.backgroundColor = .white
        collectionView?.register(TweetCell.self, forCellWithReuseIdentifier: "TweetCellID")
        let refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView.refreshControl = refresher
        
        guard let swifter = TwitterService.swifter else {return}
        swifter.showUser(userTag, success: {[weak self]
            json in
            self?.user = User(json: json)
                if let user = self?.user
                {
                    self?.set(name: user.name, verified: user.verified)
                    self?.screenNameLabel.text = "@\(user.screenName)"
                    self?.navigationItem.title = "@\(user.screenName)"
                    let largePhotoLink = user.userPhotoLink.replacingOccurrences(of: "_normal", with: "")
                    TwitterService.imageDownloader?.loadImage(for: largePhotoLink, completion: {image in
                        DispatchQueue.main.async {
                            self?.userProfileImageView.image = image
                        }
                    })
                    
                    if user.id == TwitterService.userID {
                        self?.followButton.setTitle("Logout", for: .normal)
                    }
                    else
                    {
                        if user.following {
                            self?.followButton.setTitle("Unfollow", for: .normal)
                        }
                    }
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

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never


    
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
            let fullString = NSMutableAttributedString(string:"\(name) ", attributes: [.font : UIFont(name: "Gill Sans Bold", size: 19)!, .foregroundColor: UIColor.black])
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
        guard let swifter = TwitterService.swifter, let user = user else {return}
        if user.id == TwitterService.userID {
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "oauth_token")
            userDefaults.removeObject(forKey: "oauth_token_secret")
            userDefaults.removeObject(forKey: "user_id")
            TwitterService.imageDownloader = ImageDownloader()
            view.window?.rootViewController = LoginController()
            return
        }
        
        if  user.following {
            swifter.unfollowUser(userTag, success: {
                json in
                self.followButton.setTitle("Follow", for: .normal)
            }, failure: nil)
            return
        }
        
        if !user.following {
            swifter.followUser(userTag, success: {
                json in
                self.followButton.setTitle("Unfollow", for: .normal)
            })
        }

    }
    
    @objc func refresh() {
        self.collectionView.refreshControl?.beginRefreshing()
            if let first = userTweets.first, let swifter = TwitterService.swifter {
                swifter.getTimeline(for: userTag, sinceID: first.tweetID, success: {json in
                    let newTweets = Tweet.array(of: json.array!)
                    self.userTweets.insert(contentsOf: newTweets, at: 0)
                    self.collectionView.refreshControl?.endRefreshing()
                    self.collectionView.reloadData()
                    self.requestSend = false
                    
                }, failure: {_ in self.collectionView.refreshControl?.endRefreshing()})
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
        var backgroundColor: UIColor
        switch indexPath.item % 3 {
        case 0:
            backgroundColor = UIColor(named: "SpecialBlue")!
        case 1:
            backgroundColor = UIColor(named: "SpecialGreen")!
        default:
            backgroundColor = UIColor(named: "SpecialYellow")!
        }
        cell.backgroundColor = backgroundColor
        cell.setInfoLabel(name: tweet.user.name, screenName: tweet.user.screenName, verified: tweet.user.verified)
        cell.setTweetText(text: tweet.text)
        cell.setLike(tweet.favorited)
        cell.setRetweeted(tweet.retweeted)
        cell.delegate = self
        cell.userID = tweet.user.id
        cell.tweetID = tweet.tweetID
        
        TwitterService.imageDownloader?.loadImage(for: tweet.user.userPhotoLink){
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
        measureLabel.font = UIFont(name: "Gill Sans", size: 16)
        measureLabel.lineBreakMode = .byCharWrapping
        measureLabel.translatesAutoresizingMaskIntoConstraints = false
        measureLabel.widthAnchor.constraint(equalToConstant: (width - 80)).isActive = true
        let height = measureLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 90
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)
    }
    
    
}

extension UserController: TweetCellDelegate{
    func userImageTapped(userID: String?) {
    }
    
    func retweetButtonTapped(tweetID: String?) {
        guard let swifter = TwitterService.swifter, let id = tweetID else {
            return
        }
        var newTweet: Tweet? = nil
        for searchedTweet in userTweets {
            if searchedTweet.tweetID == tweetID {
                newTweet = searchedTweet
                
            }
        }
        guard let tweet = newTweet else {return}
        if !tweet.retweeted{
            swifter.retweetTweet(forID: id, success: {_ in
                for i in 0..<self.userTweets.count {
                    if self.userTweets[i].tweetID == tweetID{
                        self.userTweets[i].retweeted = true
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        else
        {
            swifter.unretweetTweet(forID: id, success: {_ in
                for i in 0..<self.userTweets.count {
                    if self.userTweets[i].tweetID == tweetID{
                        self.userTweets[i].retweeted = false
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        
    }
    
    func likeButtonTapped(tweetID: String?) {
        guard let tweetID = tweetID, let swifter = TwitterService.swifter else {
            return
        }
        var newTweet: Tweet? = nil
        for searchedTweet in self.userTweets {
            if searchedTweet.tweetID == tweetID {
                newTweet = searchedTweet
                
            }
        }
        guard let tweet = newTweet else {return}
        if !tweet.favorited{
            swifter.favoriteTweet(forID: tweetID, success: {_ in
                for i in 0..<self.userTweets.count {
                    if self.userTweets[i].tweetID == tweetID{
                        self.userTweets[i].favorited = true
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        else
        {
            swifter.unfavoriteTweet(forID: tweetID, success: {_ in
                for i in 0..<self.userTweets.count
                {
                    if self.userTweets[i].tweetID == tweetID
                    {
                        self.userTweets[i].favorited = false
                        self.collectionView.reloadData()
                        break
                    }
                 }
            })
        }
        
    }

    
    
}
