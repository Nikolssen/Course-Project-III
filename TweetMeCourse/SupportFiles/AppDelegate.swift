//
//  AppDelegate.swift
//  TweetMeCourse
//
//  Created by Admin on 05.05.2021.
//

import UIKit
import Swifter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().unselectedItemTintColor = .darkGray
        UITabBar.appearance().tintColor = .black
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let callbackUrl = URL(string: TwitterConstants.callbackURL)!
        Swifter.handleOpenURL(url, callbackURL: callbackUrl)
        return true
    }


}

