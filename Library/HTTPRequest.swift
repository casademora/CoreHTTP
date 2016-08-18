//
//  HTTPResourceRequest.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/25/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Runes
import Result

let defaultCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
let defaultTimeout: TimeInterval = 30.seconds

private func process(request: URLRequest) -> URLRequest
{
  var request = request
  request.setValue(userAgentString(), forHTTPHeaderField: "User-Agent")
  
  //set ContentType
  //set Accept
  //set Language
  
  return request
}

private func requestFor<H: HTTPHostProtocol, R: HTTPResourceProtocol where R.ErrorType == HTTPResponseError>(resource: R, host: H, cachePolicy: URLRequest.CachePolicy, requestTimeout: TimeInterval) -> URLRequest?
{
  guard var components = URLComponents(string: host.baseURLString) else { return nil }
  
  components.path = "/" + resource.path
  components.query = convertToQueryString(dictionary: resource.queryParameters)
  
  guard let requestURL = components.url else {
    //TODO: throw an error here.
    return nil
  }
  var originalRequest = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
  originalRequest.httpMethod = resource.method.rawValue
  
  let requestToSend = process(request: originalRequest)
  return host.authenticate?(request: requestToSend) ?? requestToSend
}

@discardableResult public func request<R where R: HostedResource, R: HTTPResourceProtocol, R.ErrorType == HTTPResponseError>(resource: R, cachePolicy: URLRequest.CachePolicy = defaultCachePolicy, requestTimeout: TimeInterval = defaultTimeout, host: HTTPHost? = nil, completion: (Result<R.ResultType, R.ErrorType>) -> Void) -> URLSessionTask?
{
  guard let hostToQuery = host ?? hostRegistry.hostFor(resource) else {
    //TODO: throw an error here. No host configured is a programmer error
    return nil
  }
  guard let request = requestFor(resource: resource, host: hostToQuery, cachePolicy: cachePolicy, requestTimeout: requestTimeout) else {
    //TOD: throw an error here
    return nil
  }
  
  let task = hostToQuery.session.dataTask(with: request, completionHandler: completionHandlerForRequest(resource: resource, validate: hostToQuery.validate, completion: completion))
  task.resume()
  log(message: "Sending Request: \(request.url)")
  return task
}

private func userAgentString() -> String
{
  let bundle = Bundle.main
  let device = UIDevice.current()
  let screen = UIScreen.main()
  
  return "\(bundle.executableName))/\(bundle.bundleVersion) (\(device.model); iOS \(device.systemVersion); Scale/\(screen.scale)"
}
