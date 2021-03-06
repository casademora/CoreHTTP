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
  @IBOutlet var button: UIButton!

  private lazy var host = NASAAPODHost(apiKey: "NNKOjkoul8n1CH18TWA9gwngW1s1SmjESPjNoUFo")
  
  private func resetUI()
  {
    DispatchQueue.main.async {
      self.button.isEnabled = true
      self.progressView.isHidden = true
      self.spinner.stopAnimating()
    }
  }
  
  private func blockUI()
  {
    DispatchQueue.main.async {
      self.spinner.startAnimating()
      self.button.isEnabled = false
      self.progressView?.isHidden = false
    }
  }
  
  private func displayImage(photo: Photo) -> Photo
  {
    guard let imageURL = photo.url else { return photo }
    
    print("Loading image at: \(imageURL)")
    
    let imageData = try! Data(contentsOf: imageURL)
    print("Loaded photo of the day")
    
    DispatchQueue.main.async {
      self.imageView.image = UIImage(data: imageData)
    }
    return photo
  }
  
  private func displayError(error: HTTPResponseError) -> HTTPResponseError
  {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Darn!", style: .default, handler: nil))
    present(alert, animated: UIView.areAnimationsEnabled, completion: nil)
      
    print("Error Loading image \(error)")
    return error
  }
  
  @IBAction func reloadImage(button: UIButton)
  {
    print("Starting request for photo")
    blockUI()
    
    let response = host.request(resource: astronomyPhotoOfTheDay()) { result in
      
      print("Photo request completed")
      defer { self.resetUI() }
      
      _ = result
      .map(self.displayImage)
      .mapError(self.displayError)
    }
    progressView.observedProgress = response.progress
    
    //TODO: Make this API happen
//    host.request(resource: astronomyPhotoOfTheDay())
//      .download { photoData -> URL in $0.url }
//      .progress { value in print("Download ") }
//      .trackProgress { self.progressView.observedProgress = $0 }
//      .then(self.displayImage)
//      .finally(resetUI)
  }
  
}


