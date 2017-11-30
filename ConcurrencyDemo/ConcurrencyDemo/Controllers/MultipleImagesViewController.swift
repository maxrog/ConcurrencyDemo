//
//  MultipleImagesViewController.swift
//  ConcurrencyDemo
//
//  Created by Max Rogers on 11/30/17.
//  Copyright © 2017 Max Rogers. All rights reserved.
//

import UIKit

class MultipleImagesViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var imageViews: [UIImageView]!

    // MARK: - Slider Action
    
    // If slider isn't allowing interaction, the main queue is blocked
    @IBAction func changeSliderAlpha(_ sender: UISlider) {
        for imageView in imageViews {
            imageView.alpha = CGFloat(sender.value)
        }
    }
    
    // MARK: - Synchronous Download
    
    // This uses the main queue and blocks UI -- BAD -- don't do this.
    @IBAction func synchronousDownload(_ sender: UIButton) {
        for (index, imageView) in self.imageViews.enumerated() {
            let urlString = LargeImages.allImages[index].rawValue
            guard let url = URL(string: urlString) else { return }
            ImageDownloader.download(withURL: url, completionHandler: { (image) in
                imageView.image = image
            })
        }
    }
    
    // MARK: - Concurrent Download
    
    /// This offloads our downloading work to concurrent tasks to be run in the background on a default quality of service (priority) queue
    /// It then switches back to the main queue before performing UI changes
    /// ***NOTE***: The order of images being populated is not guaranteed
    @IBAction func concurrentDownload(_ sender: UIButton) {
        let defaultQueue = DispatchQueue.global(qos: .default)
        
        for (index, imageView) in self.imageViews.enumerated() {
            defaultQueue.async {
                let urlString = LargeImages.allImages[index].rawValue
                guard let url = URL(string: urlString) else { return }
                ImageDownloader.download(withURL: url, completionHandler: { (image) in
                    DispatchQueue.main.async {
                         imageView.image = image
                    }
                })
            }
        }
    }
    
    
    
}



