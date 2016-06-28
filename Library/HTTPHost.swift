//
//  HTTPAPIHost.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

public typealias ResponseValidationFunction = (Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>

public protocol HTTPHostProtocol: Hashable
{
  var baseURLString: String { get }
  var baseURL: NSURL { get }

  var session: URLSession { get }
  var validate: ResponseValidationFunction { get }
}

public class HTTPHost: HTTPHostProtocol
{
  public let validate: ResponseValidationFunction
  public let session: URLSession
  public private(set) var baseURLString: String
  
  public init(baseURLString: String, session: URLSession, validate: ResponseValidationFunction = defaultValidation)
  {
    self.baseURLString = baseURLString
    self.session = session
    self.validate = validate
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


private func defaultValidation(data: Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
{
  return { response in
    return response.isSuccess ?
      Result(data, failWith: .failure(response)) :
      Result(error: .failure(response))
  }
}
