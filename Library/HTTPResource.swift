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

public typealias ResourceParseFunction<ResourceType> = (Data) -> Result<ResourceType, HTTPResponseError>

public protocol HTTPResourceProtocol
{
  associatedtype ResourceType
  associatedtype ErrorType: HTTPResourceError
  
  var path: String { get }
  var method: HTTPMethod { get }
  var queryParameters: [String: String] { get }
  var parse: ResourceParseFunction<ResourceType> { get }
}

open class HTTPResource<T>: HTTPResourceProtocol
{
  public typealias ResultType = T
  public typealias ErrorType = HTTPResponseError
  
  public let path: String
  public let method: HTTPMethod
  public let queryParameters: [String : String]
  public let parse: ResourceParseFunction<ResultType>
  
  public init(path: String, method: HTTPMethod = QueriableHTTPMethod.GET, queryParameters: [String: String] = [:], parse: @escaping ResourceParseFunction<T>)
  {
    self.path = path
    self.method = method
    self.queryParameters = queryParameters
    self.parse = parse
  }
}
