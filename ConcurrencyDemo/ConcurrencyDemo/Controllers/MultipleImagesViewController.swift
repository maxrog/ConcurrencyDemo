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
    
    
}



