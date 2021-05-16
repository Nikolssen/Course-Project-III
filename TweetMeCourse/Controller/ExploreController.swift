//
//  ExploreController.swift
//  TweetMe
//
//  Created by Admin on 17.04.2021.
//

import UIKit

class ExploreController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }
    
    func configureUI(){
        view.backgroundColor = .quaternarySystemFill
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 229.0/255, green: 26.0/255, blue: 75.0/255, alpha: 1)]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        navigationItem.title = "Explore"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
}
