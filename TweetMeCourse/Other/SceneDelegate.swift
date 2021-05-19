//
//  SceneDelegate.swift
//  TweetMeCourse
//
//  Created by Admin on 05.05.2021.
//

import UIKit
import Swifter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let scene = (scene as? UIWindowScene) else { return }
        let theWindow = UIWindow(windowScene: scene)
        isLoggedIn{ [weak self] loggedIn in
            var rootVC: UIViewController
            if loggedIn {
                rootVC = MainTabBarController()
            }
            else
            {
                rootVC = LoginController(nibName: "LoginController", bundle: nil)
                TwitterService.swifter = nil
            }
            theWindow.rootViewController = rootVC
            self?.window = theWindow
            self?.window?.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first  else {return}
        let callbackUrl = URL(string: TwitterConstants.callbackURL)!
        Swifter.handleOpenURL(context.url, callbackURL: callbackUrl)
    }
    
    func isLoggedIn(completion: @escaping(Bool) -> ()) {
        let userDefaults = UserDefaults.standard
        guard let accessToken = userDefaults.string(forKey: "oauth_token"), let accessSecretToken = userDefaults.string(forKey: "oauth_token_secret") else
            {
            completion(false)
            return
            }
        let swifter = Swifter(consumerKey: TwitterConstants.consumerKey, consumerSecret: TwitterConstants.consumerSecret, oauthToken: accessToken, oauthTokenSecret: accessSecretToken)
        TwitterService.userID = userDefaults.string(forKey: "user_id")
        TwitterService.swifter = swifter
        swifter.verifyAccountCredentials(includeEntities: false, skipStatus: true, includeEmail: false, success: {_ in                                     completion(true)}, failure: {_ in completion(false)})
    }
}

