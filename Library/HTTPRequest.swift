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

private func buildRequestFor<H, R>(
    resource: R,
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

  var queryItems: [URLQueryItem] = []

  queryItems.append(contentsOf: convertToQueryItems(source: resource.queryParameters))
  components.queryItems = queryItems
  
  guard let requestURL = components.url else {
    return Result(error: .unableToBuildRequest(path: resource.path, queryParameters: resource.queryParameters))
  }
  
  var request = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
  request.httpMethod = resource.method.value

  return Result(request)
}

@discardableResult public func request<R: HostedResource & HTTPResourceProtocol>
  (
    resource: R,
    from host: HTTPHost? = nil,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  )
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
  public func canRequestResource<R: HTTPResourceProtocol & HostedResource>(resource: R) -> Bool
  {
    let resourceIsCompatible: Bool = type(of: resource.hostType) == type(of: self)
    return resourceIsCompatible
  }
  
  @discardableResult
  public func request<R: HTTPResourceProtocol & HostedResource>
  (
    resource: R,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  ) -> URLSessionTask?
  where R.ErrorType == HTTPResponseError
  {
    let request = buildRequestFor(resource: resource, host: self, cachePolicy: cachePolicy, requestTimeout: requestTimeout)

    let sessionTask = request
      .map (authentication().authenticate)
      .map { request -> URLSessionDataTask in
        
        let completionHandler = completionHandlerForRequest(resource: resource, validate: validate, completion: completion)
        return self.session.dataTask(with: request, completionHandler: completionHandler)
        
      }
      .map { task -> URLSessionDataTask in
        
        log(level: .Debug, message: "Sending Request: \(task.currentRequest?.url)")
        task.resume()
        return task
        
      }
    return sessionTask.value
  }
  
//  func download(resource)
}

/// Utilities

fileprivate func convertToQueryItems(source: [String: String]) -> [URLQueryItem]
{
  guard !source.isEmpty else { return [] }
  
  return source.flatMap { URLQueryItem(name: $0, value: $1) }
}
