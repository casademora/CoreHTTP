//
//  HTTPAPIHost.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

public protocol HTTPHostProtocol: Hashable
{
  var baseURLString: String { get }
  var baseURL: NSURL { get }

  var session: URLSession { get }
}

public class HTTPHost: HTTPHostProtocol
{
  public let session: URLSession
  public private(set) var baseURLString: String
  
  init(baseURLString: String, session: URLSession)
  {
    self.baseURLString = baseURLString
    self.session = session
  }
}

extension HTTPHostProtocol
{
  public var baseURL: NSURL
  {
    return NSURL(string: baseURLString)!
  }
  
  public var hashValue: Int
  {
    return baseURLString.hashValue
  }
}

public func ==<H: HTTPHostProtocol>(lhs: H, rhs: H) -> Bool
{
  return lhs.baseURLString == rhs.baseURLString
}
