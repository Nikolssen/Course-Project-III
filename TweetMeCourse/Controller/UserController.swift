//
//  UserController.swift
//  TweetMeCourse
//
//  Created by Admin on 20.05.2021.
//

import UIKit
import Swifter

class UserController: UIViewController {

    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var followersButton: UIButton!
    
    @IBOutlet weak var followsButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: ExtendedUser?
    let userTag: UserTag
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let swifter = TwitterService.swifter
    
        // Do any additional setup after loading the view.
    }
    
    init(userID: String, nibName: String?, bundle: Bundle?) {
        userTag = .id(userID)
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
