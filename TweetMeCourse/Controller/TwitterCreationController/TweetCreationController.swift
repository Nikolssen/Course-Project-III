//
//  TweetCreationController.swift
//  TweetMeCourse
//
//  Created by Admin on 16.05.2021.
//

import UIKit

class TweetCreationController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.delegate = self
        postButton.layer.cornerRadius = 18
        tweetTextView.layer.cornerRadius = 5
        textViewHeight.constant = UIScreen.main.bounds.height * 0.55
    }

    @IBAction func postAction(_ sender: UIButton) {
        if let text = tweetTextView.text, let swifter = TwitterService.swifter {
            swifter.postTweet(status: text)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        textViewHeight.constant = UIScreen.main.bounds.height * 0.3
        view.setNeedsLayout()
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        textViewHeight.constant = UIScreen.main.bounds.height * 0.55
        view.setNeedsLayout()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}
