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
public typealias GenerateAuthenticationCredentialsFunction = (Void) -> (HTTPAuthenticationType)

public protocol HTTPHostProtocol: Hashable
{
  var baseURLString: String { get }
  var baseURL: URL { get }

  var session: URLSession { get }

  var validate: ResponseValidationFunction { get }
  var authentication: GenerateAuthenticationCredentialsFunction { get }

  func canRequestResource<R: HTTPResourceProtocol & HostedResource>(resource: R) -> Bool
  
  @discardableResult func request<R: HostedResource & HTTPResourceProtocol>
  (
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
  
  public private(set) lazy var session: URLSession = {
    let configuration = self.configuration
    self.applyAdditionalConfiguration(configuration)
    return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
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

fileprivate func defaultAuthentication() -> HTTPAuthenticationType
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
