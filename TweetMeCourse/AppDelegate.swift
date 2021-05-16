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
        
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "SecondaryColor")
        UITabBar.appearance().tintColor = UIColor(named: "SecondaryColor")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let callbackUrl = URL(string: TwitterConstants.callbackURL)!
        Swifter.handleOpenURL(url, callbackURL: callbackUrl)
        return true
    }


}

