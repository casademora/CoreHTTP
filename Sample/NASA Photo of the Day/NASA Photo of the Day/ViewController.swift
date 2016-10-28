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
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var spinner: UIActivityIndicatorView!

  @IBAction func reloadImage(button: UIButton)
  {
    spinner.startAnimating()
    button.isEnabled = false
    request(resource: astronomyPhotoOfTheDay()) { result in
      
      guard let imageURL = result.value?.url else { return }
      
      let imageData = try! Data(contentsOf: imageURL)
      
      DispatchQueue.main.async {

        self.imageView.image = UIImage(data: imageData)
        self.spinner.stopAnimating()
        button.isEnabled = true
      }
    }
  }
}

