//
//  TweetCreationPresenter.swift
//  TweetMeCourse
//
//  Created by Admin on 23.05.2021.
//

import Foundation
import Swifter

class TweetCreationPresenter{
    
    private weak var controller: TweetCreationViewProtocol?
    
    init(controller: TweetCreationViewProtocol) {
        self.controller = controller
    }
    
    func createTweet(text: String) {
        guard let swifter = TwitterService.swifter else {return}
            swifter.postTweet(status: text, success: {
                _ in
                self.controller?.dismiss()
            })
    }
    
}
