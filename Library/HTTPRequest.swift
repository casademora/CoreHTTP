//
//  HTTPResourceRequest.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/25/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

let defaultCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
let defaultTimeout: TimeInterval = 30.seconds

private func requestFor<H: HTTPHostProtocol, R: HTTPResourceProtocol>(
    resource: R,
    host: H,
    cachePolicy: URLRequest.CachePolicy,
    requestTimeout: TimeInterval)
  -> Result<URLRequest, R.ErrorType>
    where R.ErrorType == HTTPResponseError
{
  let path = resource.path
  let requestedURL = host.baseURL.appendingPathComponent(path)
  guard var components = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
    else { return Result(error: .hostBaseURLInvalid) }

  let authentication = host.authentication?()

  var queryItems: [URLQueryItem] = []
  if let authentication = authentication, case let .QueryParameters(key, value) = authentication
  {
    queryItems.append(URLQueryItem(name: key, value: value))
  }
  queryItems.append(contentsOf: convertToQueryItems(source: resource.queryParameters))
  components.queryItems = queryItems
  
  guard let requestURL = components.url else {
    return Result(error: .unableToBuildRequest(path: resource.path, queryParameters: resource.queryParameters))
  }
  
  var request = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
  request.httpMethod = resource.method.value

  if let authentication = authentication, case let .Basic(token) = authentication
  {
    request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
  }
  else if let auth = authentication, case let .OAuth(token) = auth
  {
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  }
  return Result(request)
}

@discardableResult public func request<R: HostedResource & HTTPResourceProtocol>(
    resource: R,
    from host: HTTPHost? = nil,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void)
  -> URLSessionTask?
  where R.ErrorType == HTTPResponseError
{
  guard let hostToQuery = host ?? hostRegistry.hostFor(resource) else {
    completion(Result(error: .hostNotSpecified))
    return nil
  }

  return hostToQuery.request(resource: resource, cacheWith: cachePolicy, timeoutAfter: requestTimeout, completion: completion)
}

extension HTTPHostProtocol
{
  @discardableResult
  public func request<R: HTTPResourceProtocol & HostedResource>(
    resource: R,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  ) -> URLSessionTask?
  where R.ErrorType == HTTPResponseError
  {
//    guard type(of: resource.hostType) === type(of: self) else
//    {
//      let resourceType = String(describing: type(of: resource.hostType))
//      let hostType = String(describing: type(of: self))
//      completion(Result(error: .resourceRequestAgainstIncorrectHost(resourceType: resourceType, hostType: hostType)))
//      return nil
//    }
    
    let completionHandler = completionHandlerForRequest(resource: resource, validate: self.validate, completion: completion)
    
    let request = requestFor(resource: resource, host: self, cachePolicy: cachePolicy, requestTimeout: requestTimeout)
    let sessionTask = session.dataTask(with: request.value!, completionHandler: completionHandler)

    log(level: .Debug, message: "Sending Request: \(sessionTask.currentRequest?.url)")
    sessionTask.resume()
    return sessionTask
  }
}

/// Utilities

fileprivate func convertToQueryItems(source: [String: String]) -> [URLQueryItem]
{
  guard !source.isEmpty else { return [] }
  
  return source.flatMap { URLQueryItem(name: $0, value: $1) }
}
