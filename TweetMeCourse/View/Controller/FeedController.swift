//
//  FeedController.swift
//  TweetMeCourse
//
//  Created by Admin on 19.05.2021.
//

import UIKit

private let reuseIdentifier = "TweetCellID"

class FeedController: UICollectionViewController, FeedViewProtocol {

    
    private var tweets = [Tweet]()
    private var requestSend: Bool = false
    var presenter: FeedPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionView!.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.clearsSelectionOnViewWillAppear = false
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        collectionView?.backgroundColor = UIColor(named: "BackgroundColor")
        
        let refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView.refreshControl = refresher
                
        presenter.loadInitialTweets(action: nil)

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont(name: "Gill Sans Bold", size: 30) as Any]
        navigationItem.title = "Feed"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func update() {
        self.collectionView.reloadData()
    }
    
    func stopUpdating() {
        collectionView.refreshControl?.endRefreshing()
    }
    
    @objc private func refresh() {
        collectionView.refreshControl?.beginRefreshing()
        presenter.loadNewTweets()
    }
}

// MARK: UICollectionViewDataSource
extension FeedController
{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfTweets()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        
        let index = indexPath.item
        
        var backgroundColor: UIColor
        switch index % 3 {
        case 0:
            backgroundColor = UIColor(named: "SpecialBlue")!
        case 1:
            backgroundColor = UIColor(named: "SpecialGreen")!
        default:
            backgroundColor = UIColor(named: "SpecialYellow")!
        }
        cell.backgroundColor = backgroundColor
        
        cell.setInfoLabel(name: presenter.nameForTweet(at: index), screenName: presenter.screenNameForTweet(at: index), verified: presenter.isVerifiedUser(at: index))
        
        cell.setTweetText(text: presenter.textForTweet(at: index))
        
        cell.setLike(presenter.isLikedTweet(at: index))
        cell.setRetweeted(presenter.isRetweetedTweet(at: index))
        
        cell.index = index
        
        cell.delegate = self
        presenter.imageForTweet(at: index, action: {
            image in
            DispatchQueue.main.async {
                cell.profileImageView.image = image
            }
        })
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
            presenter.loadMoreTweets()
        }
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        let measureLabel = UILabel()
        measureLabel.text = presenter.textForTweet(at: indexPath.item)
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
    func userImageTapped(index: Int?) {
        guard let index = index else {
            return
        }
        let userID = presenter.idForUser(at: index)
        let userVC = UserController(nibName: "UserController", bundle: nil)
        let userPresenter = UserPresenter(controller: userVC, userID: userID)
        userVC.presenter = userPresenter
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    func retweetButtonTapped(index: Int?) {
        guard let index = index else {
            return
        }
        presenter.retweetTweet(at: index)
    }
        
    
    
    func likeButtonTapped(index: Int?) {
        guard let index = index else {
            return
        }
        presenter.likeTweet(at: index)
    }
}
