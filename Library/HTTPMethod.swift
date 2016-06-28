//
//  HTTPMethod.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

public protocol HTTPMethod
{
  var rawValue: String { get }
}

public enum QueriableHTTPMethod: String, HTTPMethod
{
  case GET
  case HEAD
  case OPTIONS
  case TRACE
  case CONNECT
}

public enum UpdatableHTTPMethod: String, HTTPMethod
{
  case POST
  case PUT
  case DELETE
}
