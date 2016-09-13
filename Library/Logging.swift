//
//  Logging.swift
//  CoreHTTP
//
//  Created by Saul Mora on 9/13/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation

public enum LogLevel: Int
{
  case Debug
  case Info
  case Warn
  case Error
  case Fatal
}

public protocol Logger
{
  func log(level: LogLevel, message: String)
}

extension Logger
{
  func log(level: LogLevel = .Debug, message: String)
  {
    print(message)
  }
}

public var currentLogLevel: LogLevel = .Debug
public var currentLogger: Logger?

func log(level: LogLevel = .Debug, message: String)
{
  currentLogger?.log(level: level, message: message)
}
