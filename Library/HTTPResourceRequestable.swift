//
//  HTTPResourceRequestable.swift
//  CoreHTTP
//
//  Created by Saul Mora on 11/23/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result
import Runes

public protocol HTTPResourceRequestable
{
  func canRequestResource<R>(resource: R) -> Bool
    where R: HTTPResourceProtocol & HostedResource
  
  @discardableResult func request<ResourceType>
    (
      resource: ResourceType,
      cacheWith cachePolicy: URLRequest.CachePolicy,
      timeoutAfter requestTimeout: TimeInterval
    )
    -> HTTPResponse<ResourceType.RequestedType, HTTPRequestError>
  where ResourceType: HostedResource & HTTPResourceProtocol
  
  //func download()
  //func upload()
}


extension HTTPResourceRequestable where Self: HTTPHost
{
  public func canRequestResource<R>(resource: R) -> Bool
    where R: HTTPResourceProtocol & HostedResource
  {
    return type(of: resource.hostType) == type(of: self)
  }
  
  private func dataTask(for request: URLRequest) -> URLSessionTask
  {
    return session.dataTask(with: request)
  }
  
  @discardableResult
  public func request<ResourceType>
    (
      resource: ResourceType,
      cacheWith cachePolicy: URLRequest.CachePolicy = defaultCachePolicy,
      timeoutAfter requestTimeout: TimeInterval = defaultTimeout
    ) -> HTTPResponse<ResourceType.RequestedType, HTTPRequestError>
  where ResourceType: HTTPResourceProtocol & HostedResource
  {
    let task = resource
      .request(for: self, cachePolicy: cachePolicy, timeoutAfter: requestTimeout)
      .map (authentication().authenticate)
      .map (dataTask)
      .value
    
    let response: HTTPResponse<ResourceType.RequestedType, HTTPRequestError> = HTTPResponse(task: task)
    sessionDelegate.register(pendingResponse: AnyHTTPResponse(response))
    return response
  }
}
