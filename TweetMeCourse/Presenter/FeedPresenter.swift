//
//  FeedPresenter.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import Swifter
import UIKit

class FeedPresenter{
    weak private var controller: FeedViewProtocol?
    private var tweets = [Tweet]()
    private var requestSend = false
    
    init(controller: FeedViewProtocol) {
        self.controller = controller
    }
    
    func loadNewTweets(){
        guard let swifter = TwitterService.swifter, !requestSend else {return}
        if let first = tweets.first
        {
            swifter.getHomeTimeline(count: nil, sinceID: first.tweetID, success: {json in
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
    
    func loadMoreTweets(){
        guard let swifter = TwitterService.swifter, tweets.count > 0, !requestSend else
        {return}
        requestSend = true
        swifter.getHomeTimeline(count: 10, maxID: tweets.last?.tweetID, success: {json in
            if var array = json.array {
                array.remove(at: 0)
                self.tweets.append(contentsOf: Tweet.array(of: array))
                self.controller?.update()
                self.requestSend = false
            }
        }, failure: {_ in self.requestSend = false})
    }
    
    func loadInitialTweets(action: (() -> Void)?){
        guard let swifter = TwitterService.swifter else {return}
        requestSend = true
        swifter.getHomeTimeline(count: 10, success: {json in
            guard let array = json.array else {return}
            self.tweets = Tweet.array(of: array)
            guard let controller = self.controller else {return}
            if let action = action {
                action()
            }
            controller.update()
            self.requestSend = false
        }, failure: { _ in
            self.requestSend = false
            if let action = action {
                action()
            }
        }
        )
    }
    
    func numberOfTweets() -> Int{
        return tweets.count
    }
    
    func textForTweet(at index: Int) -> String{
        return tweets[index].text
    }
    
    func nameForTweet(at index: Int) -> String {
        return tweets[index].user.name
    }
    
    func screenNameForTweet(at index: Int) -> String {
        return tweets[index].user.screenName
    }
    
    func isVerifiedUser(at index: Int) -> Bool {
        return tweets[index].user.verified
    }
    
    func isLikedTweet(at index: Int) -> Bool {
        return tweets[index].favorited
    }
    
    func isRetweetedTweet(at index: Int) -> Bool {
        return tweets[index].retweeted
    }
    
    
    func imageForTweet(at index: Int, action: @escaping ((UIImage) -> Void)){
        TwitterService.imageDownloader?.loadImage(for: tweets[index].user.userPhotoLink, completion: action)
    }
    
    func idForUser(at index: Int) -> String{
        return tweets[index].user.id
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
    
}
