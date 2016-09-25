//
//  HTTPResponse.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

func validateResponse(_ error: Error?) -> (HTTPURLResponse?) -> Result<HTTPURLResponse, HTTPResponseError>
{
  return { response in
    guard let httpResponse = response else { return Result(response, failWith: .NoResponse) }
    
    log(message: "Received Response: \(httpResponse.statusCode) - \(httpResponse.url) - \(httpResponse.allHeaderFields)")
  
    func transform(error: Error) -> Result<HTTPURLResponse, HTTPResponseError>
    {
      return Result(error: error._code == NSURLErrorCancelled ? .Cancelled : .failure(httpResponse))
    }
    
    let returnValue = error.flatMap(transform)
    return returnValue ?? Result(httpResponse)
  }
}

func completionHandlerForRequest<R: HTTPResourceProtocol>
  (
    resource: R,
    validate: @escaping ResponseValidationFunction,
    completion: @escaping (Result<R.ResultType, R.ErrorType>) -> Void
  )
    -> (Data?, URLResponse?, Error?) -> Void
    where R.ErrorType == HTTPResponseError
{
  return { (data, response, error) in
    let responseValue = Result(response as? HTTPURLResponse, failWith: .InvalidResponseType)
      >>- validateResponse(error)
      >>- validate(data)
      >>- resource.parse
    
    completion(responseValue)
  }
}
