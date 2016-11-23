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

func buildRequest<H, R>(
    for resource: R,
    host: H,
    cachePolicy: URLRequest.CachePolicy,
    requestTimeout: TimeInterval)
  -> Result<URLRequest, R.ErrorType>
    where
      H: HTTPHostProtocol,
      R: HTTPResourceProtocol,
      R.ErrorType == HTTPResponseError
{
  let path = resource.path
  let requestedURL = host.baseURL.appendingPathComponent(path)
  guard var components = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
    else { return Result(error: .hostBaseURLInvalid) }

  components.queryItems = convertToQueryItems(source: resource.queryParameters)
  
  guard let requestURL = components.url
    else { return Result(error: .unableToBuildRequest(path: resource.path, queryParameters: resource.queryParameters)) }
  
  var request = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
  request.httpMethod = resource.method.value

  return Result(request)
}


@discardableResult public func request<R>
  (
    resource: R,
    from host: HTTPHost? = nil,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  )
  -> HTTPResponse<R>
  where R: HTTPResourceProtocol & HostedResource,
        R.ErrorType == HTTPResponseError
{
  guard let hostToQuery = host ?? defaultHostRegistry.hostFor(resource) else {
    let response =  HTTPResponse<R>(result: Result(error: .hostNotSpecified))
    completion(response.result)
    return response
  }

  return hostToQuery.request(resource: resource, cacheWith: cachePolicy, timeoutAfter: requestTimeout, completion: completion)
}


/// Utilities

func convertToQueryItems(source: [String: String]) -> [URLQueryItem]
{
  guard !source.isEmpty else { return [] }
  
  return source.flatMap { URLQueryItem(name: $0, value: $1) }
}
