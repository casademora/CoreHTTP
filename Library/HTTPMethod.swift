//
//  HTTPMethod.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

public protocol HTTPMethod: RawRepresentable, ExpressibleByStringLiteral
{
  var value: String { get }
}

public enum QueriableHTTPMethod: String, HTTPMethod
{
  case unknown
  case GET
  case HEAD
  case OPTIONS
  case TRACE
  case CONNECT
  
  public var value: String
  {
    return rawValue
  }
  
  public init(stringLiteral value: StringLiteralType)
  {
    self = QueriableHTTPMethod(rawValue: value) ?? .unknown
  }
  
  public init(unicodeScalarLiteral value: StringLiteralType)
  {
    self = QueriableHTTPMethod(rawValue: value) ?? .unknown
  }
  
  public init(extendedGraphemeClusterLiteral value: StringLiteralType)
  {
    self = QueriableHTTPMethod(rawValue: value) ?? .unknown
  }
}

public enum UpdatableHTTPMethod: String, HTTPMethod
{
  case unknown
  case POST
  case PUT
  case DELETE

  public var value: String
  {
    return rawValue
  }
  
  public init(stringLiteral value: StringLiteralType)
  {
    self = UpdatableHTTPMethod(rawValue: value) ?? .unknown
  }
  
  public init(unicodeScalarLiteral value: StringLiteralType)
  {
    self = UpdatableHTTPMethod(rawValue: value) ?? .unknown
  }
  
  public init(extendedGraphemeClusterLiteral value: StringLiteralType)
  {
    self = UpdatableHTTPMethod(rawValue: value) ?? .unknown
  }
}
