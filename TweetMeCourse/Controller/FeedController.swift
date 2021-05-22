//
//  FeedController.swift
//  TweetMeCourse
//
//  Created by Admin on 19.05.2021.
//

import UIKit

private let reuseIdentifier = "TweetCellID"

class FeedController: UICollectionViewController {
    var tweets = [Tweet]()
    var requestSend: Bool = false
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.backgroundColor = UIColor(named: "BackgroundColor")
        self.refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        self.refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView.refreshControl = refresher
        collectionView?.backgroundColor = UIColor(named: "BackgroundColor")
        
        guard let swifter = TwitterService.swifter else
        {return}
        requestSend = true
        swifter.getHomeTimeline(count: 10, success: {[weak self] json in
            if let array = json.array {
                self?.tweets = Tweet.array(of: array)
                self?.collectionView.reloadData()
            }
            self?.requestSend = false
        }, failure: {[weak self] _ in self?.requestSend = false})
        
    }
    
    @objc func refresh() {
        self.collectionView.refreshControl?.beginRefreshing()
        if let first = tweets.first, let swifter = TwitterService.swifter {
            swifter.getHomeTimeline(count: nil, sinceID: first.tweetID, success: {json in
                let newTweets = Tweet.array(of: json.array!)
                self.tweets.insert(contentsOf: newTweets, at: 0)
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
                self.requestSend = false
                
            }, failure: {_ in self.collectionView.refreshControl?.endRefreshing()})
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont(name: "Gill Sans Bold", size: 30) as Any]
        navigationItem.title = "Feed"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}

// MARK: UICollectionViewDataSource
extension FeedController
{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        let tweet = tweets[indexPath.item]
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
            guard let swifter = TwitterService.swifter, tweets.count > 0, !requestSend else
            {return}
            requestSend = true
            swifter.getHomeTimeline(count: 10, maxID: tweets.last?.tweetID, success: {[weak self] json in
                if var array = json.array {
                    array.remove(at: 0)
                    self?.tweets.append(contentsOf: Tweet.array(of: array))
                    self?.collectionView.reloadData()
                    self?.requestSend = false
                }
            }, failure: {[weak self] _ in self?.requestSend = false})
        }
    }
    
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        let measureLabel = UILabel()
        measureLabel.text = tweets[indexPath.item].text
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
extension FeedController: TweetCellDelegate{
    func userImageTapped(userID: String?) {
        guard let userID = userID else {
            return
        }
        let userVC = UserController(userID: userID, nibName: "UserController", bundle: nil)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    func retweetButtonTapped(tweetID: String?, sender: TweetCell) {
        guard let swifter = TwitterService.swifter, let id = tweetID else {
            return
        }
        var newTweet: Tweet? = nil
        for searchedTweet in tweets {
            if searchedTweet.tweetID == tweetID {
                newTweet = searchedTweet
                
            }
        }
        guard let tweet = newTweet else {return}
        if !tweet.retweeted{
            swifter.retweetTweet(forID: id, success: {_ in
                for i in 0..<self.tweets.count {
                    if self.tweets[i].tweetID == tweetID{
                        self.tweets[i].retweeted = true
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        else
        {
            swifter.unretweetTweet(forID: id, success: {_ in
                for i in 0..<self.tweets.count {
                    if self.tweets[i].tweetID == tweetID{
                        self.tweets[i].retweeted = false
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        
    }
    
    func likeButtonTapped(tweetID: String?, sender: TweetCell) {
        guard let tweetID = tweetID, let swifter = TwitterService.swifter else {
            return
        }
        var newTweet: Tweet? = nil
        for searchedTweet in tweets {
            if searchedTweet.tweetID == tweetID {
                newTweet = searchedTweet
                
            }
        }
        guard let tweet = newTweet else {return}
        if !tweet.favorited{
            swifter.favoriteTweet(forID: tweetID, success: {_ in
                for i in 0..<self.tweets.count {
                    if self.tweets[i].tweetID == tweetID{
                        self.tweets[i].favorited = true
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        else
        {
            swifter.unfavoriteTweet(forID: tweetID, success: {_ in
                for i in 0..<self.tweets.count
                {
                    if self.tweets[i].tweetID == tweetID
                    {
                        self.tweets[i].favorited = false
                        self.collectionView.reloadData()
                        break
                    }
                }
            })
        }
        
    }
}
