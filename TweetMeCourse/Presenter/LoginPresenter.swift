//
//  LoginPresenter.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import Swifter

class LoginPresenter{
    
    weak private var controller: LoginViewProtocol?
    
    init(controller: LoginViewProtocol) {
        self.controller = controller
    }
    
    func login()
    {
        guard let controller = controller else {return}
        let swifter = Swifter(consumerKey: TwitterConstants.consumerKey, consumerSecret: TwitterConstants.consumerSecret)
        swifter.authorize(withProvider: controller, callbackURL: URL(string: TwitterConstants.callbackURL)!, success:{
            accessToken, _ in
            guard let accessToken = accessToken else {return}
            self.save(credentials: accessToken)
            TwitterService.swifter = Swifter(consumerKey: TwitterConstants.consumerKey, consumerSecret: TwitterConstants.consumerSecret, oauthToken: accessToken.key, oauthTokenSecret: accessToken.secret)
            TwitterService.userID = accessToken.userID
            self.controller?.loadMainView()
        }, failure: {
            _ in
            self.controller?.failure()
        })
    }
    
    func save(credentials: Credential.OAuthAccessToken)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(credentials.key, forKey: "oauth_token")
        userDefaults.set(credentials.secret, forKey: "oauth_token_secret")
        userDefaults.set(credentials.userID, forKey: "user_id")
    }
    
}
