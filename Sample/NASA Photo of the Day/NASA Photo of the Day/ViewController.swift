//
//  ViewController.swift
//  NASA Photo of the Day
//
//  Created by Saul Mora on 10/27/16.
//  Copyright © 2016 Magical Panda, LLC. All rights reserved.
//

import UIKit
import CoreHTTP

class ViewController: UIViewController
{
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var spinner: UIActivityIndicatorView!

  private lazy var host = NASAAPODHost(apiKey: "NNKOjkoul8n1CH18TWA9gwngW1s1SmjESPjNoUFo")
  
  @IBAction func reloadImage(button: UIButton)
  {
    spinner.startAnimating()
    button.isEnabled = false
    progressView.isHidden = false
    
    print("Starting request for photo")
    
    host.request(resource: astronomyPhotoOfTheDay()) { result in
      
      print("Photo request completed")
      defer {
        DispatchQueue.main.async {
          button.isEnabled = true
          self.progressView.isHidden = true
          self.spinner.stopAnimating()
        }
      }
      
      _ = result.map { photoData -> Photo in
        let imageURL = photoData.url!
        print("Loading image at: \(imageURL)")
        
        let imageData = try! Data(contentsOf: imageURL)
        print("Loaded photo of the day")
        DispatchQueue.main.async {
          self.imageView.image = UIImage(data: imageData)
        }
        return photoData
      }.mapError { error -> HTTPResponseError in
      
        print("Error Loading image \(error)")
        return error
      }
    }
  }
}

