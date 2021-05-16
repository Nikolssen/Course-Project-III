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
    
    var swifter: Swifter!
    var accToken: Credential.OAuthAccessToken?

    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 18
    }

    @IBAction func loginAction(_ sender: UIButton)
    {
        swifter = Swifter(consumerKey: TwitterConstants.consumerKey, consumerSecret: TwitterConstants.consumerSecret)
        swifter.authorize(withProvider: self, callbackURL: URL(string: TwitterConstants.callbackURL)!, success:{
        accessToken, _ in
            self.accToken = accessToken
            let userDefaults = UserDefaults.standard
            userDefaults.set(self.accToken?.key, forKey: "oauth_token")
            userDefaults.set(self.accToken?.secret, forKey: "oauth_token_secret")
            //self.getUserProfile()
            self.view.window?.rootViewController = MainTabBarController()
        }, failure : {
            _ in
            let allertVC = UIAlertController(title: "Authorization Error", message: "An authorization error happened, please try later.", preferredStyle: .actionSheet)
            allertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(allertVC, animated: true, completion: nil)
        })
    }
    
//    func getUserProfile() {
//        self.swifter.verifyAccountCredentials(includeEntities: false, skipStatus: false, includeEmail: true, success: {
//            json in
//
//
//        }, failure: nil)
//    }
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
