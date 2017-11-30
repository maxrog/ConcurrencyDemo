//
//  ImageDownloaderViewController.swift
//  ConcurrencyDemo
//
//  Created by Max Rogers on 11/29/17.
//  Copyright © 2017 Max Rogers. All rights reserved.
//

import UIKit

class ImageDownloaderViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Slider Action
    
    // If slider isn't allowing interaction, the main queue is blocked
    @IBAction func changeImageAlpha(_ sender: UISlider) {
        imageView.alpha = sender.value
    }
    
    // MARK: - Sync Download
    
    // Download a large image, blocking the main queue and the UI -- BAD -- don't do this
    @IBAction func synchronousDownload(_ sender: UIButton) {
        
    }
    
    // MARK: - Simple Async Download
    
    // Download a large image, by creating a background queue, avoiding blocking the UI
    @IBAction func simpleAsynchronousDownload(_ sender: UIButton) {
        
    }
    
    // MARK: - Improved Async Download
    
    @IBAction func asynchronousDownload(_ sender: UIButton) {
        
    }
    
    
    


}