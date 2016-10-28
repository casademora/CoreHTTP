//
//  Int+Additions.swift
//  CoreHTTP
//
//  Created by Saul Mora on 9/13/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation

public extension Int
{
  var seconds: TimeInterval
  {
    return TimeInterval(self)
  }
  
  var minutes: TimeInterval
  {
    return TimeInterval(self * 60)
  }
  
  var hours: TimeInterval
  {
    return minutes * 60
  }
  
  var days: TimeInterval
  {
    return hours * 24
  }
}
