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

extension HTTPMethodProtocol where RawValue == String
{
  public var value: String { return rawValue }
}

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
}

public enum QueriableHTTPMethod: String, HTTPMethodProtocol
{
  case unknown
  case GET
  case HEAD
  case OPTIONS
  case TRACE
  case CONNECT
}

public enum UpdatableHTTPMethod: String, HTTPMethodProtocol
{
  case unknown
  case POST
  case PUT
  case DELETE
}

