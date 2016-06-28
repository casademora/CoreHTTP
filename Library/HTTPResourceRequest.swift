//
//  HTTPResourceRequest.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/25/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Runes
import Result

let defaultCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
let defaultTimeout: TimeInterval = 30.seconds

private func requestForResource<H: HTTPHostProtocol, R: HTTPResource where R.ErrorType == HTTPResponseError>(resource: R, host: H, cachePolicy: URLRequest.CachePolicy, requestTimeout: TimeInterval) -> URLRequest?
{
  guard var components = URLComponents(string: host.baseURLString) else { return nil }
  
  components.path = "/" + resource.path
  components.query = convertToQueryString(dictionary: resource.queryParameters)
  
  guard  let requestURL = components.url else { return nil }
  return URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
}

public func request<R where R: HostedResource, R: HTTPResource, R.ErrorType == HTTPResponseError>(resource: R, cachePolicy: NSURLRequest.CachePolicy = defaultCachePolicy, requestTimeout: TimeInterval = defaultTimeout, host: HTTPHost? = nil, completion: (Result<R.ResultType, R.ErrorType>) -> Void)
{
  guard let hostToQuery = host ?? hostRegistry.hostFor(resource) else {
    //TODO: throw an error here. No host configured is a programmer error
    return
  }
  guard let request = requestForResource(resource: resource, host: hostToQuery, cachePolicy: cachePolicy, requestTimeout: requestTimeout) else { return }
  
  let task = hostToQuery.session.dataTask(with: request, completionHandler: completionHandlerForRequest(resource: resource, completion: completion))
  task.resume()
  log(message: "Sending Request: \(request.url)")
}

