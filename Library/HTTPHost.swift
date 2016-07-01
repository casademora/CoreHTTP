//
//  HTTPAPIHost.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

public typealias ResponseValidationFunction = (Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
public typealias AuthenticateRequestFunction = (request: URLRequest) -> (URLRequest)

protocol HTTPHostProtocol: Hashable
{
  var baseURLString: String { get }
  var baseURL: NSURL { get }

  var session: URLSession { get }
  var validate: ResponseValidationFunction { get }
  var authenticate: AuthenticateRequestFunction? { get }
}

public class HTTPHost: HTTPHostProtocol
{
  public let validate: ResponseValidationFunction
  public let authenticate: AuthenticateRequestFunction?
  private let configuration: URLSessionConfiguration
  public let baseURLString: String
  
  public init(baseURLString: String, configuration: URLSessionConfiguration, validate: ResponseValidationFunction = defaultValidation, authenticate: AuthenticateRequestFunction? = nil)
  {
    self.baseURLString = baseURLString
    self.configuration = configuration
    self.validate = validate
    self.authenticate = authenticate
  }
  
  public lazy var session: URLSession = {
      return URLSession(configuration: self.configuration, delegate: nil, delegateQueue: nil)
  }()

}

extension HTTPHost: Hashable
{
  var baseURL: NSURL
  {
    return NSURL(string: baseURLString)!
  }
  
  public var hashValue: Int
  {
    return baseURLString.hashValue
  }
}

public func ==<H: HTTPHost>(lhs: H, rhs: H) -> Bool
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
