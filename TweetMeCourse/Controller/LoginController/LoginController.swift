//
//  LoginController.swift
//  TweetMe
//
//  Created by Admin on 25.04.2021.
//

import UIKit
import Swifter
import SafariServices
import AuthenticationServices

class LoginController: UIViewController {
    
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 18
    }
    
    @IBAction private func loginAction(_ sender: UIButton)
    {
        let swifter = Swifter(consumerKey: TwitterConstants.consumerKey, consumerSecret: TwitterConstants.consumerSecret)
        swifter.authorize(withProvider: self, callbackURL: URL(string: TwitterConstants.callbackURL)!, success:{
            accessToken, _ in
            if let accessToken = accessToken {
                let userDefaults = UserDefaults.standard
                userDefaults.set(accessToken.key, forKey: "oauth_token")
                userDefaults.set(accessToken.secret, forKey: "oauth_token_secret")
                userDefaults.set(accessToken.userID, forKey: "user_id")
                TwitterService.swifter = Swifter(consumerKey: TwitterConstants.consumerKey, consumerSecret: TwitterConstants.consumerSecret, oauthToken: accessToken.key, oauthTokenSecret: accessToken.secret)
                TwitterService.userID = accessToken.userID
                self.view.window?.rootViewController = MainTabBarController()
            }
            
        }, failure : {
            _ in
            let allertVC = UIAlertController(title: "Authorization Error", message: "An authorization error happened, please try later.", preferredStyle: .actionSheet)
            allertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(allertVC, animated: true, completion: nil)
        })
    }
}

extension LoginController: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension LoginController: ASWebAuthenticationPresentationContextProviding{
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
    
}
