//
//  HTTPResourceRequest.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/25/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

let defaultCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
let defaultTimeout: TimeInterval = 30.seconds

extension HTTPResourceProtocol
{
  func request<HostType>
  (
    for host: HostType,
    cachePolicy: URLRequest.CachePolicy,
    timeoutAfter requestTimeout: TimeInterval
  ) -> Result<URLRequest, HTTPRequestError>
  where HostType: HTTPHostProtocol
  {
    let requestedURL = host.baseURL.appendingPathComponent(path)
    guard var components = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
      else { return Result(error: .hostBaseURLInvalid) }
    
    components.queryItems = convertToQueryItems(source: queryParameters)
    
    guard let requestURL = components.url
      else { return Result(error: .unableToBuildRequest(path: path, queryParameters: queryParameters)) }
    
    var request = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
    request.httpMethod = method.description
    
    return Result(request)
  }
}


@discardableResult public func request<ResourceType>
  (
    resource: ResourceType,
    from host: HTTPHost? = nil,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout
  )
  -> HTTPResponse<ResourceType.RequestedType, HTTPRequestError>
  where ResourceType: HTTPResourceProtocol & HostedResource
{
  guard let hostToQuery = host ?? defaultHostRegistry.hostFor(resource)
    else { return HTTPResponse(error: .hostForRequestNotFound) }

  return hostToQuery.request(resource: resource, cacheWith: cachePolicy, timeoutAfter: requestTimeout)
}


/// Utilities

func convertToQueryItems(source: [String: String]) -> [URLQueryItem]
{
  guard !source.isEmpty else { return [] }
  
  return source.flatMap { URLQueryItem(name: $0, value: $1) }
}
