//
//  UserListPresenter.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import Swifter
import UIKit

class UserListPresenter{
    weak private var controller: UserListController?
    private var users = [User]()
    private let option: UserListOption
    private let userTag: UserTag
    
    init(controller: UserListController, userID: String, option: UserListOption){
        self.controller = controller
        self.userTag = .id(userID)
        self.option = option
    }
    
    func numberOfUsers() -> Int{
        return users.count
    }

    func nameForUser(at index: Int) -> String {
        return users[index].name
    }
    
    func screenNameForUser(at index: Int) -> String {
        return users[index].screenName
    }
    
    func isVerifiedUser(at index: Int) -> Bool {
        return users[index].verified
    }
    
    func imageForTweet(at index: Int, action: @escaping ((UIImage) -> Void)){
        TwitterService.imageDownloader?.loadImage(for: users[index].userPhotoLink, completion: action)
    }
    
    func idForUser(at index: Int) -> String{
        return users[index].id
    }
    
    func title() ->String {
        switch option {
        case .followers:
            return "Followers"
        case .following:
            return "Following"
        }
    }
    
    func loadUsers() {
        guard let swifter = TwitterService.swifter else {
            return
        }
        switch option {
        case .followers:
            swifter.getUserFollowers(for: userTag, count: 50, skipStatus: true, includeUserEntities: false, success: {
                json, response, _ in
                self.users.append(contentsOf: User.array(of: json.array!))
                self.controller?.update()
                
            })
            
        case .following:
            swifter.getUserFollowing(for: userTag, count: 50, skipStatus: true, includeUserEntities: false, success: {
                json, _, _ in
                self.users.append(contentsOf: User.array(of: json.array!))
                self.controller?.update()
            })
        }
    }
    
    
    enum UserListOption {
        case followers
        case following
    }
}
