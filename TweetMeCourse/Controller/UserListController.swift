//
//  UserListController.swift
//  TweetMeCourse
//
//  Created by Admin on 22.05.2021.
//

import UIKit
import Swifter

class UserListController: UITableViewController {

    private let option: UserListOption
    private let userTag: UserTag
    private var users = [User]()
    private var requestSent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if option == .followers {
            navigationItem.title = "Followers"
        }
        else
        {
            navigationItem.title = "Following"
        }
        self.clearsSelectionOnViewWillAppear = true
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCellID")
        
        guard let swifter = TwitterService.swifter else {return}
        requestSent = true
        switch option {
        case .followers:
            swifter.getUserFollowers(for: userTag, count: 20, skipStatus: true, includeUserEntities: false, success: {
                json, response, _ in
                self.users.append(contentsOf: User.array(of: json.array!))
                self.tableView.reloadData()
                self.requestSent = false
                
            }, failure: {
                _ in
                self.requestSent = false
            })
            
        case .following:
            swifter.getUserFollowing(for: userTag, count: 20, skipStatus: true, includeUserEntities: false, success: {
                json, _, _ in
                self.users.append(contentsOf: User.array(of: json.array!))
                self.tableView.reloadData()
                self.requestSent = false
            }, failure: {
                _ in
                self.requestSent = false
            })
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCellID", for: indexPath) as! UserCell
        var backgroundColor: UIColor
        switch indexPath.row % 3 {
        case 0:
            backgroundColor = UIColor(named: "SpecialBlue")!
        case 1:
            backgroundColor = UIColor(named: "SpecialGreen")!
        default:
            backgroundColor = UIColor(named: "SpecialYellow")!
        }
        cell.contentView.backgroundColor = backgroundColor
        cell.set(name: user.name, screenName: user.screenName, verified: user.verified)
        TwitterService.imageDownloader?.loadImage(for: user.userPhotoLink){
            image in
            DispatchQueue.main.async {
                cell.userProfileImageView.image = image
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userVC = UserController(userID: user.id, nibName: "UserController", bundle: nil)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height {
//            guard let swifter = TwitterService.swifter, users.count > 0, !requestSent else
//            {return}
//            requestSent = true
//            swifter.getUserFollowing(for: userTag, cursor: <#T##String?#>, count: <#T##Int?#>, skipStatus: <#T##Bool?#>, includeUserEntities: <#T##Bool?#>, success: <#T##Swifter.CursorSuccessHandler?##Swifter.CursorSuccessHandler?##(JSON, String?, String?) -> Void#>, failure: <#T##Swifter.FailureHandler?##Swifter.FailureHandler?##(Error) -> Void#>)
//            swifter.getHomeTimeline(count: 10, maxID: tweets.last?.tweetID, success: {[weak self] json in
//                if var array = json.array {
//                    array.remove(at: 0)
//                    self?.tweets.append(contentsOf: Tweet.array(of: array))
//                    self?.collectionView.reloadData()
//                    self?.requestSend = false
//                }
//            }, failure: {[weak self] _ in self?.requestSend = false})
//        }
    }
    
    init(userTag:UserTag, option: UserListOption) {
        self.userTag = userTag
        self.option = option
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum UserListOption {
        case followers
        case following
    }
}
