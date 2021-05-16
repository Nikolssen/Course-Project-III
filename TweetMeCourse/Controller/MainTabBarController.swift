//
//  MainTabBarController.swift
//  TweetMe
//
//  Created by Admin on 15.04.2021.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(named: "SecondaryColor")
        button.backgroundColor = UIColor(named: "PrimaryColor")
        button.setImage(UIImage(systemName: "note.text.badge.plus"), for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = UIColor(named: "PrimaryColor")
        
        let unselectedImageConfiguration =
            UIImage.SymbolConfiguration(weight: .light)
        let selectedImageConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        
        let feedNav = navigationControllerWrapper(for: FeedController(), image: UIImage(systemName: "house", withConfiguration: unselectedImageConfiguration), selectedImage: UIImage(systemName:  "house.fill", withConfiguration: selectedImageConfiguration))
        
        let searchNav = navigationControllerWrapper(for: ExploreController(), image: UIImage(systemName: "magnifyingglass", withConfiguration: unselectedImageConfiguration), selectedImage: UIImage(systemName:  "magnifyingglass", withConfiguration: selectedImageConfiguration))
        
        let messageNav = navigationControllerWrapper(for: MessageMenuController(), image: UIImage(systemName: "envelope", withConfiguration: unselectedImageConfiguration), selectedImage: UIImage(systemName: "envelope.fill", withConfiguration: selectedImageConfiguration))
        let notificationsNav = navigationControllerWrapper(for: NotificationsController(), image: UIImage(systemName: "bell", withConfiguration: unselectedImageConfiguration), selectedImage: UIImage(systemName: "bell.fill", withConfiguration: selectedImageConfiguration))
        viewControllers = [feedNav, searchNav, notificationsNav, messageNav]
        configureActionButton()
    }
    @objc func actionButtonTapped(){
        print("")
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