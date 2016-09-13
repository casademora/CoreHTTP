//
//  Logging.swift
//  CoreHTTP
//
//  Created by Saul Mora on 9/13/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation

enum LogLevel: Int
{
  case Debug
  case Info
  case Warn
  case Error
  case Fatal
}

func log(level: LogLevel = .Debug, message: String)
{
  print(message)
}
