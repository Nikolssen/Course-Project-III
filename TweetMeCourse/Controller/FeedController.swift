//
//  FeedController.swift
//  TweetMe
//
//  Created by Admin on 15.04.2021.
//

import UIKit
import Swifter

class FeedController: UIViewController {
    
    var jsonResult: [JSON] = []
    var collectionView: UICollectionView?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
    }
    
    func configureUI(){
        view.backgroundColor = .quaternarySystemFill
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 229.0/255, green: 26.0/255, blue: 75.0/255, alpha: 1)]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        navigationItem.title = "Feed"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView()
        guard let collectionView = collectionView else {return}
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor), collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        collectionView.register(UINib(nibName: "TweetCell", bundle: nil), forCellWithReuseIdentifier: "TweetCellID")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension FeedController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsonResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TweetCellID", for: indexPath) as! TweetCell
        cell.userNameLabel.text = jsonResult[indexPath.row]["user"]["name"].string!
        cell.tweetTextView.text = jsonResult[indexPath.row]["text"].string!
        cell.userLoginLabel.text = jsonResult[indexPath.row]["user"]["screen_name"].string!
        return cell
    }
    
    
}
