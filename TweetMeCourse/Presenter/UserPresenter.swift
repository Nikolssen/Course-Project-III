//
//  UserPresenter.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import Swifter
import UIKit

class UserPresenter{
    weak private var controller: UserController?
    private var tweets = [Tweet]()
    private var requestSend = false
    private var userTag: UserTag
    private var user: User!
    
    init(controller: UserController, userID: String) {
        self.controller = controller
        self.userTag = .id(userID)
    }

    
    func loadNewTweets(){
        guard let swifter = TwitterService.swifter else {return}
        if let first = tweets.first, !requestSend
        {
            
            swifter.getTimeline(for: userTag, count: nil, sinceID: first.tweetID, success: {json in
                let newTweets = Tweet.array(of: json.array!)
                self.tweets.insert(contentsOf: newTweets, at: 0)
                self.controller?.stopUpdating()
                self.controller?.update()
                self.requestSend = false
                
            }, failure: {_ in
                self.controller?.stopUpdating()
                self.requestSend = false
            })
        }
        else {
            loadInitialTweets(action: {
                self.controller?.stopUpdating()
            })
        }
        
    }
    
    func loadUser(){
        guard let swifter = TwitterService.swifter else {return}
        requestSend = true
        swifter.showUser(userTag, success: {
            json in
            self.user = User(json: json)
            self.controller?.setUserName(self.user.name, screenName: self.user.screenName, verified: self.user.verified)
            let largePhotoLink = self.user.userPhotoLink.replacingOccurrences(of: "_normal", with: "")
            TwitterService.imageDownloader?.loadImage(for: largePhotoLink, completion:
            {image in
                    DispatchQueue.main.async {
                        self.controller?.setUserImage(image)
                    }
            })
                
            if self.user.id == TwitterService.userID {
                    self.controller?.setFollowText(text: "Logout")
                }
                else
                {
                    if self.user.following {
                        self.controller?.setFollowText(text: "Unfollow")
                    }
                    else
                    {
                        self.controller?.setFollowText(text: "Follow")
                    }
                }
            self.requestSend = false
            self.loadInitialTweets(action: nil)
            
        })
    }
    
    func loadMoreTweets(){
        guard let swifter = TwitterService.swifter, tweets.count > 0, !requestSend else
        {return}
        requestSend = true
        swifter.getTimeline(for: userTag, count: 10, sinceID: tweets.last?.tweetID, success: {json in
            if var array = json.array {
                array.remove(at: 0)
                self.tweets.append(contentsOf: Tweet.array(of: array))
                self.controller?.update()
                self.requestSend = false
            }
        }, failure: {_ in self.requestSend = false})
    }
    
    
    func numberOfTweets() -> Int{
        return tweets.count
    }
    
    func textForTweet(at index: Int) -> String{
        return tweets[index].text
    }
    
    func nameForTweet(at index: Int) -> String {
        return user.name
    }
    
    func screenNameForTweet(at index: Int) -> String {
        return user.screenName
    }
    
    func isVerifiedUser(at index: Int) -> Bool {
        return user.verified
    }
    
    func isLikedTweet(at index: Int) -> Bool {
        return tweets[index].favorited
    }
    
    func isRetweetedTweet(at index: Int) -> Bool {
        return tweets[index].retweeted
    }
    
    func imageForTweet(at index: Int, action: @escaping ((UIImage) -> Void)){
        TwitterService.imageDownloader?.loadImage(for: user.userPhotoLink, completion: action)
    }
    
    func idForUser(at index: Int) -> String{
        return tweets[index].user.id
    }
    
    func loadInitialTweets(action: (() -> Void)?){
        guard let swifter = TwitterService.swifter else {return}
        requestSend = true
        swifter.getTimeline(for: userTag, count: 10, excludeReplies: true, includeRetweets: true, success: {json in
            guard let array = json.array else {return}
            self.tweets = Tweet.array(of: array)
            guard let controller = self.controller else {return}
            if let action = action {
                action()
            }
            controller.update()
            self.requestSend = false
        }, failure: { _ in
            
            if let action = action {
                action()
            }
            self.requestSend = false
        })
    }
    
    func likeTweet(at index: Int){
        
        guard let swifter = TwitterService.swifter, !requestSend else { return }
        requestSend = true
        if tweets[index].favorited {
            swifter.unfavoriteTweet(forID: tweets[index].tweetID, includeEntities: false, tweetMode: .compat, success: { _ in
                self.tweets[index].favorited = false
                self.controller?.update()
                self.requestSend = false
            }, failure: { _ in
                self.requestSend = false
            })
        }
        else {
            swifter.favoriteTweet(forID: tweets[index].tweetID, includeEntities: false, tweetMode: .compat, success: { _ in
                self.tweets[index].favorited = true
                self.controller?.update()
                self.requestSend = false
            }, failure: {
                _ in
                self.requestSend = false
            })
        }
    }
    
    func retweetTweet(at index: Int){
        guard let swifter = TwitterService.swifter, !requestSend else { return }
        requestSend = true
        if tweets[index].retweeted {
            swifter.unretweetTweet(forID: tweets[index].tweetID, trimUser: true, tweetMode: .compat, success:
            { _ in
                self.tweets[index].retweeted = false
                self.controller?.update()
                self.requestSend = false
            }, failure: { _ in
                self.requestSend = false
            })
        }
        else {
            swifter.retweetTweet(forID: tweets[index].tweetID, trimUser: true, tweetMode: .compat, success: { _ in
                self.tweets[index].retweeted = true
                self.controller?.update()
                self.requestSend = false
            }, failure: {
                _ in
                self.requestSend = false
            })
        }
    }
    
    func followAction() {
        guard let swifter = TwitterService.swifter, let user = user else {return}
        if user.id == TwitterService.userID {
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "oauth_token")
            userDefaults.removeObject(forKey: "oauth_token_secret")
            userDefaults.removeObject(forKey: "user_id")
            TwitterService.imageDownloader = ImageDownloader()

            return
        }
        
        if  user.following {
            swifter.unfollowUser(userTag, success: {
                json in
                self.controller?.setFollowText(text: "Follow")
                self.user.following = false
            }, failure: nil)
            return
        }
        
        if !user.following {
            swifter.followUser(userTag, success: {
                json in
                self.controller?.setFollowText(text: "Unfollow")
                self.user.following = true
            })
        }
    }
    
    func getUserID() -> String {
        return user.id
    }
}

