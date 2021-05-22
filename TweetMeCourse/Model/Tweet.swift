//
//  Tweet.swift
//  TweetMeCourse
//
//  Created by Admin on 17.05.2021.
//

import Foundation
import Swifter

struct Tweet {
    let text: String
    let tweetID: String
    var favorited: Bool
    var retweeted: Bool
    let user: User

    init?(json: JSON) {
        guard let text = json["text"].string,
              let user = User(json: json["user"]),
              let tweetID = json["id_str"].string,
              let favorited = json["favorited"].bool,
              let retweeted = json["retweeted"].bool
        else {return nil}
        self.text = text
        self.user = user
        self.tweetID = tweetID
        self.favorited = favorited
        self.retweeted = retweeted
    }
    
    static func array(of jsonTweets: [JSON]) -> [Tweet] {
        var tweets = [Tweet]()
        for jsonTweet in jsonTweets {
            if let tweet = Tweet(json:jsonTweet) {
                tweets.append(tweet)
            }
        }
        return tweets
    }
}

