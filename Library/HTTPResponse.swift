//
//  HTTPResponse.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

func validateResponse(_ error: Error?) -> (HTTPURLResponse) -> Result<HTTPURLResponse, HTTPResponseError>
{
  return { httpResponse in
    
    log(level: .Debug, message: "Received Response: \(httpResponse.statusCode) - \(httpResponse.url) - \(httpResponse.allHeaderFields)")
  
    func transform(error: Error) -> Result<HTTPURLResponse, HTTPResponseError>
    {
      return Result(error: error._code == NSURLErrorCancelled ? .cancelled : .responseFailure(httpResponse))
    }
    
    return error.flatMap(transform) ?? Result(httpResponse)
  }
}

func completionHandlerForRequest<R: HTTPResourceProtocol>
  (
    resource: R,
    validate: @escaping ResponseValidationFunction,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  )
    -> (Data?, URLResponse?, Error?) -> Void
    where R.ErrorType == HTTPResponseError
{
  return { (data, response, error) in
  
    let responseValue = Result(response as? HTTPURLResponse, failWith: .invalidResponseType)
      >>- validateResponse(error)
      >>- validate(data)
      >>- resource.parse

    completion(responseValue)
  }
}

func completionHandlerForRequest<R: HTTPResourceProtocol>
  (
    resource: R,
    validate: @escaping ResponseValidationFunction,
    completion: @escaping (Result<R.ResourceType, R.ErrorType>) -> Void
  ) -> (Data?, URLResponse?, Error?) -> Void
  where R.ErrorType == HTTPRequestError
{
  return { (data, response, error) in
    completion(.failure(.unknown))
  }
}

public protocol HTTPProgressMonitorable
{
  var progress: Progress { get }
}

public protocol HTTPResponseProtocol
{
  associatedtype ResponseType
  associatedtype ErrorType = HTTPResponseError
}

public class HTTPResponse<R: HTTPResourceProtocol>: HTTPResponseProtocol
{
  public typealias ResponseType = R.ResourceType
  
  var result: Result<ResponseType, HTTPResponseError>
  public let progress: Progress?
  let task: URLSessionTask?
  
  init(task: URLSessionTask? = nil, result: Result<ResponseType, HTTPResponseError> = .failure(.unknown))
  {
    self.task = task
    self.progress = nil
    self.result = result
  }
  
//  func download<T>(f: (R.ResourceType) -> T) -> T
//  {
//    return result.map(f)
////wait for response to complete
////kick off download
////    return f(self)
//  }
}

