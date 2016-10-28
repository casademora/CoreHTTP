//
//  AppDelegate.swift
//  NASA Photo of the Day
//
//  Created by Saul Mora on 10/27/16.
//  Copyright © 2016 Magical Panda, LLC. All rights reserved.
//

import UIKit
import CoreHTTP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
  {
    register(host: NASAAPODHost(apiKey: "NNKOjkoul8n1CH18TWA9gwngW1s1SmjESPjNoUFo"))
    return true
  }
}

