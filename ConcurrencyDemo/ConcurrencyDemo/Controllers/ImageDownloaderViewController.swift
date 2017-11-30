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
        imageView.alpha = CGFloat(sender.value)
    }
    
    // MARK: - Sync Download
    
    // Download a large image, blocking the main queue and the UI -- BAD -- don't do this
    @IBAction func synchronousDownload(_ sender: UIButton) {
        guard let url = URL(string: LargeImages.seaLion.rawValue) else { return }
        
        do {
            let imageData = try Data(contentsOf: url)
            let image = UIImage(data: imageData)
            imageView.image = image
        } catch let error {
            print("Error creating data from url", error)
            return
        }
    }
    
    // MARK: - Simple Async Download
    
    // Download a large image by creating a background queue, avoiding blockage of the UI and main queue
    @IBAction func simpleAsynchronousDownload(_ sender: UIButton) {
        guard let url = URL(string: LargeImages.shark.rawValue) else { return }
        
        // Create our own serial queue
        let downloadQueue = DispatchQueue(label: "download", attributes: [])
        
        downloadQueue.async {
            do {
                let imageData = try Data(contentsOf: url)
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } catch let error {
                print("Error creating data from url", error)
                return
            }
        }
    }
    
    // MARK: - Improved Async Download
    
    // Download a large image in a global queue and use a completion closure
    @IBAction func asynchronousDownload(_ sender: UIButton) {
        downloadLargeImage { (image) in
            self.imageView.image = image
        }
    }
    
    // MARK: - Completion Handler Method for Async Download
    
    func downloadLargeImage(completionHandler handler: @escaping (UIImage) -> Void) {
        // .background == low priority
        // .userInitiated == normal priorty
        // .userInteractive == high priority
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: LargeImages.whale.rawValue) else { return }
            do {
                let imageData = try Data(contentsOf: url)
                guard let image = UIImage(data: imageData) else { return }
                
                // Good practice to put completion handlers in main queue
                DispatchQueue.main.async {
                    handler(image)
                }
            } catch let error {
                print("Error creating data from url", error)
                return
            }
        }
    }

}
