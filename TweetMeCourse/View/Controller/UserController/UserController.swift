//
//  UserController.swift
//  TweetMeCourse
//
//  Created by Admin on 20.05.2021.
//

import UIKit


class UserController: UIViewController, UserViewProtocol {

    
    
    
    var presenter: UserPresenter!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var followersButton: UIButton!
    
    @IBOutlet weak var followsButton: UIButton!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureUI()
        
        collectionView?.register(TweetCell.self, forCellWithReuseIdentifier: "TweetCellID")
        let refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView.refreshControl = refresher
        
        presenter.loadUser()
        //presenter.loadInitialTweets(action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureUI(){
        collectionView?.backgroundColor = UIColor(named: "BackgroundColor")
        followsButton.layer.cornerRadius = 30/2
        followersButton.layer.cornerRadius = 30/2
        followButton.layer.cornerRadius = 30/2
        
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = 90/2
        userProfileImageView.backgroundColor = .white
    }
    
    func update() {
        self.collectionView.reloadData()
    }
    
    func stopUpdating() {
        collectionView.refreshControl?.endRefreshing()
    }
    func setUserImage(_ image: UIImage) {
        userProfileImageView.image = image
    }
    
    func setUserName(_ name: String, screenName: String, verified: Bool) {
        set(name: name, verified: verified)
        screenNameLabel.text = "@\(screenName)"
        navigationItem.title = "@\(screenName)"
    }
    
    func setFollowText(text: String) {
        followButton.setTitle(text, for: .normal)
    }
    
    func backToLogin() {
        let loginController = LoginController(nibName: "LoginController", bundle: nil)
        let loginPresenter = LoginPresenter(controller: loginController)
        loginController.presenter = loginPresenter
        view.window?.rootViewController = loginController
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
        let userListVC = UserListController(style: .plain)
        let id = presenter.getUserID()
        let presenter = UserListPresenter(controller: userListVC, userID: id, option: .followers)
        userListVC.presenter = presenter
        navigationController?.pushViewController(userListVC, animated: true)
    }
    @IBAction func showFollowingAction(_ sender: Any) {
        let userListVC = UserListController(style: .plain)
        let id = presenter.getUserID()
        let presenter = UserListPresenter(controller: userListVC, userID: id, option: .following)
        userListVC.presenter = presenter
        navigationController?.pushViewController(userListVC, animated: true)
    }
    
    @IBAction func followAction(_ sender: Any) {
        presenter.followAction()
    }
    
    @objc func refresh() {
        self.collectionView.refreshControl?.beginRefreshing()
        presenter.loadNewTweets()
    }
}

extension UserController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfTweets()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TweetCellID", for: indexPath) as! TweetCell
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
        cell.delegate = self
        cell.index = index
        presenter.imageForTweet(at: index, action: {
            image in
            DispatchQueue.main.async {
                cell.profileImageView.image = image
            }
        })
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
            presenter.loadMoreTweets()
        }
    }
    
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

extension UserController: TweetCellDelegate{
    func userImageTapped(index: Int?) {
    }
    
    func retweetButtonTapped(index: Int?) {
        guard let index = index else {return}
        presenter.retweetTweet(at: index)
    }
    
    func likeButtonTapped(index: Int?) {
        guard let index = index else {return}
        presenter.likeTweet(at: index)
    }
    
}
