//
//  HTTPMethod.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

public protocol HTTPMethodProtocol: RawRepresentable
{
  var value: String { get }
}

/*
extension HTTPMethodProtocol where RawValue == String: ExpressibleByStringLiteral, RawRepresentable
{
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
    self = self.init(rawValue: value) ?? .unknown
  }
}
 */

public enum AnyHTTPMethod: String, HTTPMethodProtocol
{
  case unknown
  case GET
  case HEAD
  case OPTIONS
  case TRACE
  case CONNECT
  case POST
  case PUT
  case DELETE
  
  public var value: String { return rawValue }
}

public enum QueriableHTTPMethod: String, HTTPMethodProtocol
{
  case unknown
  case GET
  case HEAD
  case OPTIONS
  case TRACE
  case CONNECT
  
  public var value: String { return rawValue }
}

public enum UpdatableHTTPMethod: String, HTTPMethodProtocol
{
  case unknown
  case POST
  case PUT
  case DELETE
  
  public var value: String { return rawValue }
}

