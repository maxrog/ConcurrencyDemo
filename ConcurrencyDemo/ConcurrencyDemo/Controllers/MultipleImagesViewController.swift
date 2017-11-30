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
    
    // MARK: - Download Using Main Queue (which is also serial)
    
    // This uses the main queue and blocks UI -- BAD -- don't do this.
    @IBAction func synchronousDownload(_ sender: UIButton) {
        clearImageViews()
        
        for (index, imageView) in self.imageViews.enumerated() {
            let urlString = LargeImages.allImages[index].rawValue
            guard let url = URL(string: urlString) else { return }
            ImageDownloader.download(withURL: url, completionHandler: { (image) in
                imageView.image = image
            })
        }
        
    }
    
    // MARK: - Download Using Concurrent Dispatch Queues
    
    /// This offloads our downloading work to concurrent tasks to be run in the background on a default quality of service (priority) queue (UI IS NOT BLOCKED!)
    /// It then switches back to the main queue before performing UI changes
    /// ***NOTE***: The order of images being populated is not guaranteed
    /// ***NOTE***: Tasks do not have to wait - so they download faster
    @IBAction func concurrentDownload(_ sender: UIButton) {
        clearImageViews()
        
        let concurrentQueue = DispatchQueue.global(qos: .default)
        
        for (index, imageView) in self.imageViews.enumerated() {
            concurrentQueue.async {
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
    
    // MARK: - Download Using Serial Dispatch Queues
    /// This offloads our downloading work to a background serial queue (UI IS NOT BLOCKED!)
    /// It then switches back to the main queue before performing UI changes
    /// ***NOTE***: The order of images being populated is guaranteed to be in order 1, 2, 3, 4
    /// ***NOTE***: Tasks wait for the one in front of them to finish - finishes slower than concurrent
    @IBAction func serialDownload(_ sender: UIButton) {
        clearImageViews()
        
        let serialQueue = DispatchQueue(label: "SerialDownloader")
        
        for (index, imageView) in self.imageViews.enumerated() {
            serialQueue.async {
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


// MARK: - Helper Function to Clear Images on New Downloader

extension MultipleImagesViewController {
    
    func clearImageViews() {
        for imageView in imageViews {
            imageView.image = nil
        }
    }
    
}



