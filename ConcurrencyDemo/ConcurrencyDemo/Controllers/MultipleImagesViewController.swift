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
    
    var customOperationQueue = OperationQueue()

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
        if !isDownloading() {
            clearImageViews()
            
            for (index, imageView) in self.imageViews.enumerated() {
                let urlString = LargeImages.allImages[index].rawValue
                guard let url = URL(string: urlString) else { return }
                ImageDownloader.download(withURL: url, completionHandler: { (image) in
                    imageView.image = image
                })
            }
        }
    }
    
    // MARK: - Download Using Concurrent Dispatch Queues
    
    /// This offloads our downloading work to concurrent tasks to be run in the background on a default quality of service (priority) queue (UI IS NOT BLOCKED!)
    /// It then switches back to the main queue before performing UI changes
    /// ***NOTE***: The order of images being populated is not guaranteed
    /// ***NOTE***: Tasks do not have to wait - so they download faster
    @IBAction func concurrentDownload(_ sender: UIButton) {
        if !isDownloading() {
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
    }
    
    // MARK: - Download Using Serial Dispatch Queues
    /// This offloads our downloading work to a background serial queue (UI IS NOT BLOCKED!)
    /// It then switches back to the main queue before performing UI changes
    /// ***NOTE***: The order of images being populated is guaranteed to be in order 1, 2, 3, 4
    /// ***NOTE***: Tasks wait for the one in front of them to finish - finishes slower than concurrent
    @IBAction func serialDownload(_ sender: UIButton) {
        if !isDownloading() {
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
    
    // MARK: Download using Operation Queue
    
    /// Download images using default operation queue
    /// By default it is concurrent so order is not guaranteed
    @IBAction func operationDownload(_ sender: UIButton) {
        clearImageViews()
        for (index, imageView) in self.imageViews.enumerated() {
            customOperationQueue.addOperation {
                let urlString = LargeImages.allImages[index].rawValue
                guard let url = URL(string: urlString) else { return }
                ImageDownloader.download(withURL: url, completionHandler: { (image) in
                    OperationQueue.main.addOperation {
                        imageView.image = image
                    }
                })
            }
        }
    }
    
    // MARK: - Download using Operation Queue With Set Order
    
    /// Use dependencies to ensure order and act similar to a serial queue
    @IBAction func setOrderOperationDownload(_ sender: UIButton) {
         clearImageViews()
        
        // First Operation
        let operation0 = BlockOperation {
            let urlString = LargeImages.allImages[0].rawValue
            guard let url = URL(string: urlString) else { return }
            ImageDownloader.download(withURL: url, completionHandler: { (image) in
                OperationQueue.main.addOperation {
                    self.imageViews[0].image = image
                }
            })
        }
        
        // Second Operation
        let operation1 = BlockOperation {
            let urlString = LargeImages.allImages[1].rawValue
            guard let url = URL(string: urlString) else { return }
            ImageDownloader.download(withURL: url, completionHandler: { (image) in
                OperationQueue.main.addOperation {
                    self.imageViews[1].image = image
                }
            })
        }
        
        // Third Operation
        let operation2 = BlockOperation {
            let urlString = LargeImages.allImages[2].rawValue
            guard let url = URL(string: urlString) else { return }
            ImageDownloader.download(withURL: url, completionHandler: { (image) in
                OperationQueue.main.addOperation {
                    self.imageViews[2].image = image
                }
            })
        }
        
        // Fourth Operation
        let operation3 = BlockOperation {
            let urlString = LargeImages.allImages[3].rawValue
            guard let url = URL(string: urlString) else { return }
            ImageDownloader.download(withURL: url, completionHandler: { (image) in
                OperationQueue.main.addOperation {
                    self.imageViews[3].image = image
                }
            })
        }
        
        // Add dependencies to ensure order
        operation1.addDependency(operation0)
        operation2.addDependency(operation1)
        operation3.addDependency(operation2)
        
        // Log completions
        operation0.completionBlock = {
            print("First image downloaded")
        }
        operation1.completionBlock = {
            print("Second image downloaded")
        }
        operation2.completionBlock = {
            print("Third image downloaded")
        }
        operation3.completionBlock = {
            print("Fourth image downloaded")
        }
        
        // Add operations to queue
        customOperationQueue.addOperation(operation0)
        customOperationQueue.addOperation(operation1)
        customOperationQueue.addOperation(operation2)
        customOperationQueue.addOperation(operation3)
    }
    
    // MARK: - Cancel operations that have not finished executing
    
    /// Cancel will work for set order operations since they have dependencies and are
    /// waiting in queue for higher operation to finish
    @IBAction func cancelOperations(_ sender: UIButton) {
        customOperationQueue.cancelAllOperations()
    }
    
    
}


// MARK: - Helper Function to Clear Images on New Downloader

extension MultipleImagesViewController {
    
    func clearImageViews() {
        for imageView in imageViews {
            imageView.image = nil
        }
    }
    
    func isDownloading() -> Bool {
        for imageView in imageViews {
            if imageView.image == nil {
                return true
            }
        }
        return false
    }
    
}



