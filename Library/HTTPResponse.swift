//
//  HTTPResponse.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result
import Runes

func validateResponse(_ error: NSError?) -> (HTTPURLResponse?) -> Result<HTTPURLResponse, HTTPResponseError>
{
  return { response in
    guard let httpResponse = response else { return Result(response, failWith: .NoResponse) }
    
    log(message: "Received Response: \(httpResponse.statusCode) - \(httpResponse.url) - \(httpResponse.allHeaderFields)")
  
    if let error = error
    {
      return Result(error: .Failure(statusCode: httpResponse.httpStatusCode, error: error))
    }
    return Result(httpResponse)
  }
}

func completionHandlerForRequest<R: HTTPResource where R.ErrorType == HTTPResponseError>(resource: R, validate: ResponseValidationFunction, completion: (Result<R.ResultType, R.ErrorType>) -> Void) -> (Data?, URLResponse?, NSError?) -> Void
{
  return { (data, response, error) in
    _ = Result(response as? HTTPURLResponse, failWith: .InvalidResponseType)
      >>- validateResponse(error)
      >>- validate(data)
      >>- resource.parse
      >>- completion
  }
}
