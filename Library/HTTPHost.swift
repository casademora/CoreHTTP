//
//  HTTPAPIHost.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

public typealias ResponseValidationFunction = (Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
public typealias AuthenticateURLRequestFunction = (_ request: URLRequest) -> (URLRequest)
public typealias PreprocessRequestFunction = (URLRequest) -> URLRequest

public typealias AuthenticationToken = String
public enum AuthenticationType
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

public typealias GenerateAuthenticationCredentialsFunction = (Void) -> (AuthenticationType)

public protocol HTTPHostProtocol: Hashable
{
  var baseURLString: String { get }
  var baseURL: URL { get }

  var session: URLSession { get }

  var validate: ResponseValidationFunction { get }
  var authentication: GenerateAuthenticationCredentialsFunction { get }

  func canRequestResource<R: HTTPResourceProtocol & HostedResource>(resource: R) -> Bool
  
  @discardableResult func request<R: HostedResource & HTTPResourceProtocol>(
    resource: R,
    cacheWith cachePolicy: URLRequest.CachePolicy,
    timeoutAfter requestTimeout: TimeInterval,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  ) -> URLSessionTask?
  where R.ErrorType == HTTPResponseError
}

open class HTTPHost: HTTPHostProtocol
{
  public let baseURLString: String
  
  public let preprocessRequest: PreprocessRequestFunction?
  public let validate: ResponseValidationFunction
  public let authentication: GenerateAuthenticationCredentialsFunction
  
  private let configuration: URLSessionConfiguration
  
  public init(baseURLString: String,
              configuration: URLSessionConfiguration,
              preprocessRequests: PreprocessRequestFunction? = nil,
              validate: @escaping ResponseValidationFunction = defaultValidation,
              authentication: @escaping GenerateAuthenticationCredentialsFunction = defaultAuthentication)
  {
    self.baseURLString = baseURLString
    self.configuration = configuration
    self.preprocessRequest = preprocessRequests
    self.validate = validate
    self.authentication = authentication
  }
  
  open func applyAdditionalConfiguration(_ configuration: URLSessionConfiguration)
  {
    configuration.httpAdditionalHeaders =
      [
        "User-Agent": buildUserAgent()
      ]
  }
  
  public lazy var session: URLSession = {
    self.applyAdditionalConfiguration(self.configuration)
    return URLSession(configuration: self.configuration, delegate: nil, delegateQueue: nil)
  }()
}

extension HTTPHost: Hashable
{
  public var baseURL: URL
  {
    return URL(string: baseURLString)!
  }
  
  public var hashValue: Int
  {
    return baseURLString.hashValue
  }
}

public func ==<H: HTTPHost>(lhs: H, rhs: H) -> Bool
{
  return lhs.baseURLString == rhs.baseURLString
}

fileprivate func defaultValidation(data: Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
{
  return { response in
     response.isSuccess ?
      Result(data, failWith: .responseFailure(response)) :
      Result(error: .responseFailure(response))
  }
}

fileprivate func defaultAuthentication() -> AuthenticationType
{
  return .none
}

private func buildUserAgent() -> String
{
  let bundle = Bundle.main
  let device = UIDevice.current
  let screen = UIScreen.main
  
  return "\(bundle.executableName))/\(bundle.bundleVersion) (\(device.model); \(device.systemName) \(device.systemVersion); Scale/\(screen.scale))"
}
