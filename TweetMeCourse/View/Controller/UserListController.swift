//
//  UserListController.swift
//  TweetMeCourse
//
//  Created by Admin on 22.05.2021.
//

import UIKit


class UserListController: UITableViewController, UserListViewProtocol {

    

    var presenter: UserListPresenter!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = presenter.title()
        self.clearsSelectionOnViewWillAppear = true
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCellID")
        
        presenter.loadUsers()

        
    }
    func update() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfUsers()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCellID", for: indexPath) as! UserCell
        var backgroundColor: UIColor
        switch index % 3 {
        case 0:
            backgroundColor = UIColor(named: "SpecialBlue")!
        case 1:
            backgroundColor = UIColor(named: "SpecialGreen")!
        default:
            backgroundColor = UIColor(named: "SpecialYellow")!
        }
        cell.contentView.backgroundColor = backgroundColor
        
        cell.set(name: presenter.nameForUser(at: index), screenName: presenter.screenNameForUser(at: index), verified: presenter.isVerifiedUser(at: index))
        presenter.imageForTweet(at: index, action: {
            image in
            DispatchQueue.main.async {
                cell.userProfileImageView.image = image
            }
        })

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let userVC = UserController(nibName: "UserController", bundle: nil)
        let userPresenter = UserPresenter(controller: userVC, userID: presenter.idForUser(at: index))
        userVC.presenter = userPresenter
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
       

}
