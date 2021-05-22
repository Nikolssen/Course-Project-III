//
//  MainTabBarController.swift
//  TweetMe
//
//  Created by Admin on 15.04.2021.
//

import UIKit
import Swifter

class MainTabBarController: UITabBarController {
    
    var accToken: Credential.OAuthAccessToken?
    var swifter: Swifter!
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.backgroundColor = UIColor(named: "SpecialBlue")
        button.setImage(UIImage(systemName: "note.text.badge.plus"), for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = .white
        
        let unselectedImageConfiguration =
            UIImage.SymbolConfiguration(weight: .light)
        let selectedImageConfiguration = UIImage.SymbolConfiguration(weight: .heavy)
        let feedVC = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let feedNav = navigationControllerWrapper(for: feedVC, image: UIImage(systemName: "house", withConfiguration: unselectedImageConfiguration), selectedImage: UIImage(systemName:  "house.fill", withConfiguration: selectedImageConfiguration))
        feedNav.tabBarItem.title = "Feed"

        let userNav = navigationControllerWrapper(for: UserController(userID: TwitterService.userID!, nibName: "UserController", bundle: nil), image: UIImage(systemName: "person", withConfiguration: unselectedImageConfiguration), selectedImage: UIImage(systemName:  "person.fill", withConfiguration: selectedImageConfiguration))
        userNav.tabBarItem.title = "My profile"
        
        viewControllers = [feedNav, userNav]
        configureActionButton()
        
    }
    @objc func actionButtonTapped(){
        present(TweetCreationController(), animated: true, completion: nil)
    }
    
    func navigationControllerWrapper(for rootViewController: UIViewController, image: UIImage?, selectedImage: UIImage?) -> UINavigationController{
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.selectedImage = selectedImage
        return navigationController
    }
    
    func configureActionButton(){
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionButton.heightAnchor.constraint(equalToConstant: 50), actionButton.widthAnchor.constraint(equalToConstant: 50), actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84), actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)])
        
    }
    
}
