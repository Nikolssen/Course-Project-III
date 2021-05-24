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
    var presenter: LoginPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 18
    }
    
    @IBAction private func loginAction(_ sender: UIButton)
    {
        presenter.login()
    }
}
extension LoginController: LoginViewProtocol{
    
    func loadMainView() {
        self.view.window?.rootViewController = MainTabBarController()
    }
    
    func failure() {
        let allertVC = UIAlertController(title: "Authorization Error", message: "An authorization error happened, please try later.", preferredStyle: .actionSheet)
        allertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(allertVC, animated: true, completion: nil)
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

