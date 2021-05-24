//
//  UserViewProtocol.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import UIKit

protocol UserViewProtocol: NSObject{
    func refresh()
    func stopUpdating()
    func backToLogin()
    func setUserImage(_ image: UIImage)
    func setUserName(_ name: String, screenName: String, verified: Bool)
    func setFollowText(text: String)
}
