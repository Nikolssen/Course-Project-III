//
//  ImageDownloadOperation.swift
//  TweetMeCourse
//
//  Created by Admin on 21.05.2021.
//

import Foundation
import UIKit

class ImageDownloadOperation: Operation {
    private var url: String
    var dataTask: URLSessionDataTask?
    var completion: [((_ image: UIImage) -> Void)] = []
    var image: UIImage?
    
    init(url: String) {
        self.url = url
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        guard let url = URL(string: self.url) else {return}
        self.dataTask = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard let self = self else
            {return}
            if data == nil {
                return
            }
            if self.isCancelled
            {
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.image = image
                for block in self.completion{
                        block(image)
                    }
            }
            
        }
        if self.isCancelled {
            return
        }
        
        self.dataTask?.resume()
    }
    
    override func cancel() {
        super.cancel()
        self.dataTask?.cancel()
    }
}
