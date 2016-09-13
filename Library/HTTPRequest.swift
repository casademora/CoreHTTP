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

private func process(request: URLRequest) -> URLRequest
{
  //set ContentType
  //set Accept
  //set Language
  
  return request
}

private func requestFor<H: HTTPHostProtocol, R: HTTPResourceProtocol>(resource: R, host: H, cachePolicy: URLRequest.CachePolicy, requestTimeout: TimeInterval) -> Result<URLRequest, R.ErrorType>
  where R.ErrorType == HTTPResponseError
{
  guard var components = URLComponents(string: host.baseURLString) else { return Result(error: .hostBaseURLInvalid) }
  
  components.path = "/" + resource.path
  components.query = convertToQueryString(dictionary: resource.queryParameters)
  
  guard let requestURL = components.url else {
    return Result(error: .unableToBuildRequest(path: resource.path, queryParameters: resource.queryParameters))
  }
  
  var originalRequest = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
  originalRequest.httpMethod = resource.method.rawValue
  
  let requestToSend = process(request: originalRequest)
  return Result( host.authenticate?(requestToSend) ?? requestToSend )
}

@discardableResult public func request<R>(resource: R, cachePolicy: URLRequest.CachePolicy = defaultCachePolicy, requestTimeout: TimeInterval = defaultTimeout, host: HTTPHost? = nil, completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void) -> URLSessionTask?
  where R: HostedResource, R: HTTPResourceProtocol, R.ErrorType == HTTPResponseError
{
  guard let hostToQuery = host ?? hostRegistry.hostFor(resource) else {
    completion(Result(error: .hostNotSpecified))
    return nil
  }
  
  let completionHandler = completionHandlerForRequest(resource: resource, validate: hostToQuery.validate, completion: completion)
  
  let request = requestFor(resource: resource, host: hostToQuery, cachePolicy: cachePolicy, requestTimeout: requestTimeout)
    >>- { Result(hostToQuery.session.dataTask(with: $0, completionHandler: completionHandler)) }
  
  let task = request.map { requestTask -> URLSessionTask in
    log(level: .Debug, message: "Sending Request: \(requestTask.currentRequest?.url)")
    requestTask.resume()
    return requestTask
  }
  
  return task.value
}

/// Utilities

private func convertToQueryString(dictionary: [String: String]) -> String?
{
  guard !dictionary.isEmpty else {  return nil }
  
  return dictionary
    .map { "\($0)=\($1)" }
    .joined(separator: "&")
}

