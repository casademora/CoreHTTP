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
  
  public static func <(left: LogLevel, right: LogLevel) -> Bool
  {
    return left.rawValue < right.rawValue
  }
  
  public static func <=(left: LogLevel, right: LogLevel) -> Bool
  {
    return left.rawValue <= right.rawValue
  }
  
  public static func >(left: LogLevel, right: LogLevel) -> Bool
  {
    return left.rawValue > right.rawValue
  }
}

public protocol Logger
{
  func log(level: LogLevel, message: String)
}

extension Logger
{
  func log(level: LogLevel = .Debug, message: String)
  {
    guard level < currentLogLevel else { return }
    print(message)
  }
}

public var currentLogLevel: LogLevel = .Debug
public var currentLogger: Logger? = ConsoleLogger()

func log(level: LogLevel = .Debug, message: String)
{
  currentLogger?.log(level: level, message: message)
}


struct ConsoleLogger: Logger
{
}
