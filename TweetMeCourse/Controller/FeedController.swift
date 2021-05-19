//
//  FeedController.swift
//  TweetMeCourse
//
//  Created by Admin on 17.05.2021.
//

import UIKit
import Swifter

class FeedController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet] = []
    
    override func viewDidLoad() {

        super.viewDidLoad()
        configureUI()
        tableView.register(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetID")
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let swifter = TwitterService.swifter else
        {return}
        swifter.getHomeTimeline(count: 10, success: {[weak self] json in
            if let array = json.array {
                self?.tweets = Tweet.array(of: array)
                self?.tableView?.reloadData()
            }
            print(json)
        })
    }
    
    func configureUI(){
        view.backgroundColor = UIColor(named: "BackgroundColor")
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 229.0/255, green: 26.0/255, blue: 75.0/255, alpha: 1)]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        navigationItem.title = "Feed"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
}

extension FeedController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //if tweets[indexPath.row][]
        return nil
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tweetID = tweets[indexPath.row].tweetID
        let isFavorited = tweets[indexPath.row].favorited
        if (!isFavorited) {
            let favorAction = UIContextualAction(style: .normal, title: nil, handler: { _,_,_ in
                TwitterService.swifter?.favoriteTweet(forID: tweetID)
            })
            favorAction.image = UIImage(systemName: "heart")
            favorAction.backgroundColor = .systemPink
            return UISwipeActionsConfiguration(actions: [favorAction])
        }
        else {
            let unfavorAction = UIContextualAction(style: .normal, title: nil, handler: {_,_,_ in TwitterService.swifter?.unfavoriteTweet(forID: tweetID)
            })
            unfavorAction.image = UIImage(systemName: "heart.slash")
            unfavorAction.backgroundColor = .systemPink
            return UISwipeActionsConfiguration(actions: [unfavorAction])
        }
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        <#code#>
//    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
}

extension FeedController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetID") as! TweetCell
        cell.tweetView.layer.cornerRadius = 20
        cell.textView.text = tweets[indexPath.row].text
        cell.userNameLabel.text = tweets[indexPath.row].user.name
        cell.screenNameLabel.text = "@" + tweets[indexPath.row].user.screenName
        return cell
    }
    
    
}
