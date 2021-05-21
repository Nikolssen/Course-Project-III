//
//  UserCell.swift
//  TweetMeCourse
//
//  Created by Admin on 20.05.2021.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfileImage.contentMode = .scaleAspectFit
        userProfileImage.clipsToBounds = true
        userProfileImage.layer.cornerRadius = 48/2
        userProfileImage.backgroundColor = .white
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func set(name: String, screenName: String, verified: Bool = false) {
        let string = NSMutableAttributedString(string: "\(name)", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(named: "PrimaryColor")!])
        if (verified) {
            string.append(NSAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "checkmark")!)))
        }
        usernameLabel.attributedText = string
        screenNameLabel.text = "@\(screenName)"
    }
    
}
