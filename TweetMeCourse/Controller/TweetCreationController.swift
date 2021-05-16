//
//  TweetCreationController.swift
//  TweetMeCourse
//
//  Created by Admin on 16.05.2021.
//

import UIKit

class TweetCreationController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.delegate = self
    }

    @IBAction func postAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
