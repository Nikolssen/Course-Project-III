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
    
    func getData(from url: String, completion: @escaping(Data?, URLResponse?, Error?) -> ()) {
        
        DispatchQueue.global(qos: .utility).async {
            if let url = URL(string: url){
                URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
            }
        
        }
    }
    
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
        })
        self.queue.addOperation(operation)
    }
//
//    func cancelDownload(for url: String) {
//
//    }
    
}
