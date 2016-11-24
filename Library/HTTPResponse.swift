//
//  HTTPResponse.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

public protocol HTTPResponseProtocol: Hashable
{
  associatedtype ValueType
  associatedtype ErrorType = HTTPResponseError
  
  func progress(_ handler: @escaping (Float) -> Void) -> Self
  func observe(_ observer: @escaping (Progress) -> Void) -> Self
  func download(_ transform: @escaping (ValueType) -> URL) -> Self
  func complete(_ handler: @escaping (ValueType) -> Void) -> Self
  func error(_ handler: @escaping (ErrorType) -> Void) -> Self
}


//func validateResponse(_ error: Error?) -> (HTTPURLResponse) -> Result<HTTPURLResponse, HTTPResponseError>
//{
//  return { httpResponse in
//    
//    log(level: .Debug, message: "Received Response: \(httpResponse.statusCode) - \(httpResponse.url) - \(httpResponse.allHeaderFields)")
//  
//    func transform(error: Error) -> Result<HTTPURLResponse, HTTPResponseError>
//    {
//      return Result(error: error._code == NSURLErrorCancelled ? .cancelled : .responseFailure(httpResponse))
//    }
//    
//    return error.flatMap(transform) ?? Result(httpResponse)
//  }
//}
//
//func completionHandlerForRequest<R: HTTPResourceProtocol>
//  (
//    resource: R,
//    validate: @escaping ResponseValidationFunction
//  )
//    -> (Data?, URLResponse?, Error?) -> Void
//{
//  return { (data, response, error) in
//  
//    _ = Result(response as? HTTPURLResponse, failWith: .invalidResponseType)
//      >>- validateResponse(error)
//      >>- validate(data)
//      >>- resource.parse
//
////    completion(responseValue)
//  }
//}

public class HTTPResponse<R, E: HTTPResourceError>: HTTPResponseProtocol
{
  public typealias ValueType = R
  private var result: Result<R, E>?
  
  private lazy var progress: Progress = Progress()
  let task: URLSessionTask?
  
  init(task: URLSessionTask? = nil)
  {
    self.task = task
  }
  
  init(error: E)
  {
    task = nil
    result = .failure(error)
  }
  
  private func begin(task: URLSessionTask?)
  {
    guard let task = task else { return }
    
    log(level: .Debug, message: "Sending Request: \(task.currentRequest?.url)")
    task.resume()
  }
  
  private var progressHandler: ((Float) -> Void)?
  @discardableResult
  public func progress(_ handler: @escaping (Float) -> Void) -> Self
  {
    progressHandler = handler
    return self
  }
  
  private var observeHandler: ((Progress) -> Void)?
  @discardableResult
  public func observe(_ handler: @escaping (Progress) -> Void) -> Self
  {
    observeHandler = handler
    return self
  }

  private var downloadHandler: ((R) -> URL)?
  @discardableResult
  public func download(_ transform: @escaping (R) -> URL) -> Self
  {
    //start request here if not started
    downloadHandler = transform
    return self
  }
  
  private var completeHandler: ((R) -> Void)?
  @discardableResult
  public func complete(_ handler: @escaping (R) -> Void) -> Self
  {
    completeHandler = handler
    //start request here if not started
    begin(task: task)
    return self
  }

  private var errorHandler: ((HTTPResponseError) -> Void)?
  @discardableResult
  public func error(_ handler: @escaping (HTTPResponseError) -> Void) -> Self
  {
    errorHandler = handler
    return self
  }
}

extension HTTPResponse: Hashable
{
  public var hashValue: Int
  {
    return 1
  }

  static public func ==(left: HTTPResponse, right: HTTPResponse) -> Bool
  {
    return true
  }
}


struct AnyHTTPResponse
{
//  private let _progress: ((Float) -> Void) -> AnyHTTPResponse
//  private let _observe: ((Progress) -> Void) -> AnyHTTPResponse
//  private let download: ((AnyHTTPResponse) -> Void) -> AnyHTTPResponse

  init<H>(_ response: H) where H: HTTPResponseProtocol
  {
//    _progress = { AnyHTTPResponse(response.progress($0)) }
//    _observe = { AnyHTTPResponse(response.observe($0)) }
  }
}

//extension AnyHTTPResponse: HTTPResponseProtocol
//{
//  func progress(_ handler: (Float) -> Void) -> AnyHTTPResponse
//  {
//    
//  }
//}

extension AnyHTTPResponse: Equatable
{
  static public func ==(left: AnyHTTPResponse, right: AnyHTTPResponse) -> Bool
  {
    return false
  }
}

extension AnyHTTPResponse: Hashable
{
  public var hashValue: Int
  {
    return 1
  }
}

