//
//  LoginViewProtocol.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import AuthenticationServices

protocol LoginViewProtocol: NSObject, ASWebAuthenticationPresentationContextProviding{
    
    func loadMainView()
    func failure()
}
