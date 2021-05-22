//
//  ImageDownloader.swift
//  TweetMeCourse
//
//  Created by Admin on 21.05.2021.
//

import Foundation
import UIKit

class ImageDownloader {
    private let queue = OperationQueue()
    private var operations = Dictionary<String,ImageDownloadOperation>()
    private var imageCache = NSCache<NSString, UIImage>()

    
    func loadImage(for url: String, completion: @escaping ((UIImage) -> Void)) {
        let nsstring = NSString(string: url)
        if let image = imageCache.object(forKey: nsstring) {
            completion(image)
            return
        }
        if let operation = operations[url] {
            operation.completion.append({image in completion(image)})
            return
        }
        
        let operation = ImageDownloadOperation(url: url)
        operations[url] = operation
        operation.completion.append({
                [weak self]
                image in completion(image)
            self?.imageCache.setObject(image, forKey: nsstring)
            self?.operations.removeValue(forKey: url)
        })
        self.queue.addOperation(operation)
    }

    
}
