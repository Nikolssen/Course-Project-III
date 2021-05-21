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
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.clearsSelectionOnViewWillAppear = false
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        guard let swifter = TwitterService.swifter else
        {return}
        requestSend = true
        swifter.getHomeTimeline(count: 10, success: {[weak self] json in
            if let array = json.array {
                self?.tweets = Tweet.array(of: array)
                self?.collectionView.reloadData()
            }
            self?.requestSend = false
            print(json)
        }, failure: {[weak self] _ in self?.requestSend = false})
    }
        func configureUI(){
            view.backgroundColor = UIColor(named: "BackgroundColor")
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 229.0/255, green: 26.0/255, blue: 75.0/255, alpha: 1)]
            navigationController?.navigationBar.largeTitleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
            navigationItem.title = "Feed"
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            collectionView?.backgroundColor = UIColor(named: "BackgroundColor")
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
        measureLabel.font = UIFont.systemFont(ofSize: 14)
        measureLabel.lineBreakMode = .byCharWrapping
        measureLabel.translatesAutoresizingMaskIntoConstraints = false
        measureLabel.widthAnchor.constraint(equalToConstant: (width - 80)).isActive = true
        let height = measureLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 50
        
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

    }
    
    func likeButtonTapped(tweetID: String?, sender: TweetCell) {
        guard let tweetID = tweetID else {
            return
        }
        guard let swifter = TwitterService.swifter else {return}
        swifter.favoriteTweet(forID: tweetID, success: {json in
            print(json)
            sender.setLike(true)
        })
    }
    
    
}
