//
//  ImageDownloader.swift
//  ConcurrencyDemo
//
//  Created by Max Rogers on 11/30/17.
//  Copyright © 2017 Max Rogers. All rights reserved.
//

import UIKit

class ImageDownloader {
    
    static func download(withURL url: URL, completionHandler completion: @escaping (UIImage) -> Void) {
        do {
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else { return }
            completion(image)
        } catch let error {
            print("Error creating data from url", error)
            return
        }
    }
    
}
