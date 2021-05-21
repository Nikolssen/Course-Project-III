//
//  TwitterService.swift
//  TweetMeCourse
//
//  Created by Admin on 05.05.2021.
//

import Foundation
import Swifter

struct TwitterConstants {
    static let consumerKey = "xOCrn1Ptf4lTxyAPHnMgyuzdr"
    static let consumerSecret = "YGOlwRNaHXm7dq1jBQ7YkgqJ5KAjWvsu2eXE3IYFNTIAjwgwWq"
    static let callbackURL = "tweetmecourse://"
}

class TwitterService {

    static var swifter: Swifter?
    static var userID: String?
//    static var token: String?
//    static var secretKey: String?
    static let imageDownloader = ImageDownloader()
}




