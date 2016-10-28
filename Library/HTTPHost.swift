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
  case QueryParameters(String, AuthenticationToken)
  case Basic(AuthenticationToken)
  case OAuth(AuthenticationToken)
}

public typealias GenerateAuthenticationCredentialsFunction = (Void) -> (AuthenticationType)

protocol HTTPHostProtocol: Hashable
{
  var baseURLString: String { get }
  var baseURL: URL { get }

  var session: URLSession { get }

  var validate: ResponseValidationFunction { get }
  var authentication: GenerateAuthenticationCredentialsFunction? { get }
}

open class HTTPHost: HTTPHostProtocol
{
  public let baseURLString: String
  
  public let preprocessRequest: PreprocessRequestFunction?
  public let validate: ResponseValidationFunction
  public let authentication: GenerateAuthenticationCredentialsFunction?
  
  private let configuration: URLSessionConfiguration
  
  public init(baseURLString: String,
              configuration: URLSessionConfiguration,
              preprocessRequests: PreprocessRequestFunction? = nil,
              validate: @escaping ResponseValidationFunction = defaultValidation,
              authentication: GenerateAuthenticationCredentialsFunction? = nil)
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
  var baseURL: URL
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

private func defaultValidation(data: Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
{
  return { response in
     response.isSuccess ?
      Result(data, failWith: .responseFailure(response)) :
      Result(error: .responseFailure(response))
  }
}

private func buildUserAgent() -> String
{
  let bundle = Bundle.main
  let device = UIDevice.current
  let screen = UIScreen.main
  
  return "\(bundle.executableName))/\(bundle.bundleVersion) (\(device.model); \(device.systemName) \(device.systemVersion); Scale/\(screen.scale))"
}
