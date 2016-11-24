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

public typealias ResourceParseResult<RequestedType> = Result<RequestedType, HTTPResponseError>
public typealias ResourceParseFunction<RequestedType> = (Data) -> ResourceParseResult<RequestedType>

public protocol HTTPResourceProtocol
{
  associatedtype RequestedType
  associatedtype HTTPMethod: HTTPMethodProtocol
  
  var path: String { get }
  var method: HTTPMethod { get }
  var queryParameters: [String: String] { get }
  var parse: (Data) -> ResourceParseResult<RequestedType> { get }
}

open class HTTPResource<RequestedType, HTTPMethod: HTTPMethodProtocol>: HTTPResourceProtocol
{
  public let path: String
  public let method: HTTPMethod
  public let queryParameters: [String : String]
  public let parse: ResourceParseFunction<RequestedType>
  
  public init(path: String, method: HTTPMethod, queryParameters: [String: String] = [:], parse: @escaping ResourceParseFunction<RequestedType>)
  {
    self.path = path
    self.method = method
    self.queryParameters = queryParameters
    self.parse = parse
  }
}

open class QueriableHTTPResource<RequestedType>: HTTPResource<RequestedType, QueriableHTTPMethod>
{
  public override init(path: String, method: QueriableHTTPMethod = .GET, queryParameters: [String: String] = [:], parse: @escaping ResourceParseFunction<RequestedType>)
  {
    super.init(path: path, method: method, queryParameters: queryParameters, parse: parse)
  }
}

open class UpdatableHTTPResource<RequestedType>: HTTPResource<RequestedType, UpdatableHTTPMethod>
{
  public override init(path: String, method: UpdatableHTTPMethod = .POST, queryParameters: [String: String] = [:], parse: @escaping ResourceParseFunction<RequestedType>)
  {
    super.init(path: path, method: method, queryParameters: queryParameters, parse: parse)
  }
}

open class DownloadableHTTPResource<RequestedType>: QueriableHTTPResource<RequestedType>
{

}
