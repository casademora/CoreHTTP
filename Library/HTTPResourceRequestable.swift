//
//  HTTPResourceRequestable.swift
//  CoreHTTP
//
//  Created by Saul Mora on 11/23/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

public protocol HTTPResourceRequestable
{
  func canRequestResource<R>(resource: R) -> Bool
    where R: HTTPResourceProtocol & HostedResource
  
  @discardableResult func request<R>
    (
    resource: R,
    cacheWith cachePolicy: URLRequest.CachePolicy,
    timeoutAfter requestTimeout: TimeInterval,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
    ) -> HTTPResponse<R>
  where R: HostedResource & HTTPResourceProtocol,
        R.ErrorType == HTTPResponseError
}


extension HTTPResourceRequestable where Self: HTTPHostProtocol
{
  public func canRequestResource<R>(resource: R) -> Bool
    where R: HTTPResourceProtocol & HostedResource
  {
    let resourceIsCompatible: Bool = type(of: resource.hostType) == type(of: self)
    return resourceIsCompatible
  }
  
  private func buildDataTask<R>(for resource: R, with completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void) -> (URLRequest) -> URLSessionTask
    where R: HTTPResourceProtocol,
          R.ErrorType == HTTPResponseError
  {
    let responseValidation = validate
    let session = self.session
    return { request in
      let completionHandler = completionHandlerForRequest(resource: resource, validate: responseValidation, completion: completion)
      return session.dataTask(with: request, completionHandler: completionHandler)
    }
  }
  
  private func beginTask(task: URLSessionTask) -> URLSessionTask
  {
    log(level: .Debug, message: "Sending Request: \(task.currentRequest?.url)")
    task.resume()
    return task
  }
  
  @discardableResult
  public func request<R>
    (
    resource: R,
    cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
    timeoutAfter requestTimeout: TimeInterval = defaultTimeout,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
    ) -> HTTPResponse<R>
  where R: HTTPResourceProtocol & HostedResource,
    R.ErrorType == HTTPResponseError
  {
    let request = buildRequest(for: resource, host: self, cachePolicy: cachePolicy, requestTimeout: requestTimeout)
    
    let sessionTask = request
      .map (authentication().authenticate)
      .map (buildDataTask(for: resource, with: completion))
      .map (beginTask)
    
    return HTTPResponse(task: sessionTask.value!)
  }
}
