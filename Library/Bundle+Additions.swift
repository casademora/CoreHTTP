//
//  NSBundle+Additions.swift
//
//
//  Created by Saul Mora on 6/26/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation
import Runes

extension Bundle
{
  var executableName: String
  {
    let bundleExecutableKey = kCFBundleExecutableKey as String
    let bundleIdentifierKey = kCFBundleIdentifierKey as String
    
    let executableName =
      (infoDictionary >>- { $0[bundleExecutableKey] })
        ?? (infoDictionary >>- { $0[bundleIdentifierKey] })
    return executableName as? String ?? "Unable to Determine Executable Name"
  }
  
  var bundleVersion: String
  {
    let bundleVersionKey = kCFBundleVersionKey as String
    let bundleShortVersionkey = "CFBundleShortVersionString"
    
    let version = (infoDictionary >>- { $0[bundleVersionKey] })
      ?? (infoDictionary >>- { $0[bundleShortVersionkey] })

    return version as? String ?? "0.0.0"
  }
}
