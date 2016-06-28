//
//  HTTPResource.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Argo
import Runes
import Result
import Foundation

public protocol HostedResource
{
  var HostType: AnyClass { get }
}

public typealias ResourceParseFunction<T> = (Data) -> Result<T, HTTPResponseError>
public typealias ResourceValidationFunction = (Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>

public protocol HTTPResource
{
  associatedtype ResultType
  associatedtype ErrorType: HTTPAPIError
  
  var path: String { get }
  var method: HTTPMethod { get }
  var queryParameters: [String: String] { get }
  var parse: ResourceParseFunction<ResultType> { get }
  var validate: ResourceValidationFunction { get }
}

public class JSONHTTPResource<T>: HTTPResource
{
  public typealias ResultType = T
  public typealias ErrorType = HTTPResponseError
  
  public let path: String
  public let method: HTTPMethod
  public let queryParameters: [String : String]
  public let parse: ResourceParseFunction<ResultType>
  public let validate: ResourceValidationFunction
  
  public init(path: String, method: HTTPMethod = QueriableHTTPMethod.GET, queryParameters: [String: String] = [:], parse: ResourceParseFunction<T>, validation: ResourceValidationFunction = defaultValidation)
  {
    self.path = path
    self.method = method
    self.queryParameters = queryParameters
    self.parse = parse
    self.validate = validation
  }
}

private func defaultValidation(data: Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
{
  return { response in
    return response.isSuccess ?
      Result(data, failWith: .failure(response)) :
      Result(error: .failure(response))
  }
}
