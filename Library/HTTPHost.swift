//
//  HTTPAPIHost.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation
import Result

public typealias ResponseValidationFunction = (Data?) -> (HTTPURLResponse) -> Result<Data, HTTPResponseError>
public typealias AuthenticateURLRequestFunction = (_ request: URLRequest) -> (URLRequest)
public typealias PreprocessRequestFunction = (URLRequest) -> URLRequest
public typealias GenerateAuthenticationCredentialsFunction = (Void) -> (HTTPAuthenticationType)

public protocol HTTPHostProtocol: Hashable, HTTPResourceRequestable
{
  var baseURLString: String { get }
  var baseURL: URL { get }

  var session: URLSession { get }

  var validate: ResponseValidationFunction { get }
  var authentication: GenerateAuthenticationCredentialsFunction { get }
}

open class HTTPHost: HTTPHostProtocol
{
  public let baseURLString: String
  public private(set) lazy var baseURL: URL = URL(string: self.baseURLString) ?? URL(fileURLWithPath: "/")
  public private(set) lazy var session: URLSession = self.buildSession()
  private let configuration: URLSessionConfiguration
  
  internal private(set) lazy var sessionDelegate: HTTPHostSessionDelegate = HTTPHostSessionDelegate()
  public let preprocessRequest: PreprocessRequestFunction?
  public let validate: ResponseValidationFunction
  public var authentication: GenerateAuthenticationCredentialsFunction
  {
    didSet
    {
      rebuildSession()
    }
  }

  public init(baseURLString: String,
              configuration: URLSessionConfiguration = .default,
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
  
  func setAuthentication(type: HTTPAuthenticationType)
  {
    authentication = { type }
  }
  
  private func rebuildSession()
  {
    session = buildSession()
  }
  
  private func buildSession() -> URLSession
  {
    let configuration = self.configuration
    self.applyAdditionalConfiguration(configuration)
    return URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
  }
  
  open func applyAdditionalConfiguration(_ configuration: URLSessionConfiguration)
  {
    var addtionalHeaders: [String: Any] = [:]
    addtionalHeaders["User-Agent"] = buildUserAgent()
    
    let authType = authentication()
    if authType.isStaticHeaderAuthentication
    {
      addtionalHeaders["Authorization"] = authType.authenticationHeaderValue
    }
    configuration.httpAdditionalHeaders = addtionalHeaders
  }
}

extension HTTPHost: Hashable
{
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
