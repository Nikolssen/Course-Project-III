//
//  MainTabBarController.swift
//  TweetMe
//
//  Created by Admin on 15.04.2021.
//

import UIKit


class MainTabBarController: UITabBarController {
    
    
    private let actionButton: UIButton = {
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
        let feedPresenter = FeedPresenter(controller: feedVC)
        feedVC.presenter = feedPresenter
        
        let feedNav = UINavigationController(rootViewController: feedVC)
        feedNav.tabBarItem.title = "Feed"
        feedNav.tabBarItem.image = UIImage(systemName: "house", withConfiguration: unselectedImageConfiguration)
        feedNav.tabBarItem.selectedImage = UIImage(systemName:  "house.fill", withConfiguration: selectedImageConfiguration)

        let userVC = UserController(nibName: "UserController", bundle: nil)
        let userPresenter = UserPresenter(controller: userVC, userID: TwitterService.userID!)
        userVC.presenter = userPresenter
        
        let userNav = UINavigationController(rootViewController:userVC)
        userNav.tabBarItem.title = "My profile"
        userNav.tabBarItem.image = UIImage(systemName: "person", withConfiguration: unselectedImageConfiguration)
        userNav.tabBarItem.selectedImage = UIImage(systemName:  "person.fill", withConfiguration: selectedImageConfiguration)
        
        configureActionButton()
        
        viewControllers = [feedNav, userNav]
        
        
    }
    @objc func actionButtonTapped(){
        let tweetVC = TweetCreationController(nibName: "TweetCreationController", bundle: nil)
        let tweetPresenter = TweetCreationPresenter(controller: tweetVC)
        tweetVC.presenter = tweetPresenter
        present(tweetVC, animated: true, completion: nil)
    }

    func configureActionButton(){
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionButton.heightAnchor.constraint(equalToConstant: 50), actionButton.widthAnchor.constraint(equalToConstant: 50), actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84), actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)])
    }
    
}
