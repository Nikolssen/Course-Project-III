//
//  User.swift
//  TweetMeCourse
//
//  Created by Admin on 18.05.2021.
//

import Foundation
import Swifter


struct User {
    let screenName: String
    let userPhotoLink: String
    let id: String
    let name: String
    let verified: Bool
    
  //  let creationDate: String
    var following: Bool
    
    init?(json: JSON){
        guard let screenName = json["screen_name"].string,
              let userPhotoLink = json["profile_image_url"].string,
              let id = json["id_str"].string,
              let name = json["name"].string,
              let verified = json["verified"].bool,
       //       let creationDateString = json["created_at"].string,
              let following = json["following"].bool
        else {return nil}
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z yyyy"
//        guard let date = dateFormatter.date(from: creationDateString)  else {
//            return nil
//        }
        
        self.screenName = screenName
        self.userPhotoLink = userPhotoLink
        self.id = id
        self.name = name
        self.verified = verified
        self.following = following

       // self.creationDate =
    }
    static func array(of jsonUsers: [JSON]) -> [User] {
        var users = [User]()
        for jsonUser in jsonUsers {
            if let user = User(json:jsonUser) {
                users.append(user)
            }
        }
        return users
    }
}
