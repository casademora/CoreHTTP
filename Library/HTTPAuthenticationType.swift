//
//  HTTPAuthenticationType.swift
//  CoreHTTP
//
//  Created by Saul Mora on 11/18/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation

public typealias AuthenticationToken = String
public enum HTTPAuthenticationType
{
  case none
  case queryParameters(String, AuthenticationToken)
  case basic(AuthenticationToken)
  case oauth(AuthenticationToken)
  
  var authenticationHeaderValue: String
  {
    switch self
    {
    case .basic(let token):
      return "Basic \(token)"
    case .oauth(let token):
      return "Bearer \(token)"
    default:
      return ""
    }
  }
  
  func authenticate(request: URLRequest) -> URLRequest
  {
    func authentication() -> (URLRequest) -> URLRequest
    {
      switch self
      {
      case .queryParameters:
        return authenticateQuery
      case .basic(_), .oauth(_):
        return authenticateHeader
      case .none:
        return noAuthentication
      }
    }
    let function = authentication()
    return function(request)
  }
  
  private func noAuthentication(request: URLRequest) -> URLRequest
  {
    return request
  }
  
  private func authenticateHeader(request: URLRequest) -> URLRequest
  {
    var authenticatedRequest = request
    authenticatedRequest.setValue(authenticationHeaderValue, forHTTPHeaderField: "Authorization")
    return authenticatedRequest
  }
  
  private func authenticateQuery(request: URLRequest) -> URLRequest
  {
    guard
      let url = request.url,
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      case let .queryParameters(key, value) = self
    else { return request }
    
    var queryItems = components.queryItems ?? []
    queryItems.append(URLQueryItem(name: key, value: value))
    components.queryItems = queryItems
    
    var authenticatedRequest = request
    authenticatedRequest.url = components.url
    return authenticatedRequest
  }
}
