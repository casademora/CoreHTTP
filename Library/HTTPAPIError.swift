//
//  HTTPAPIError.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

public protocol HTTPAPIError: ErrorProtocol
{
}

public enum HTTPRequestError: HTTPAPIError
{
  case Unknown
}

import Argo

public enum HTTPResponseError: HTTPAPIError
{
  case Unknown
  case Cancelled
  case NoResponse
  case NoResponseData
  case InvalidResponseType
  case Failure(statusCode: HTTPStatusCode, description: String)
  
  case DecodingFailed(description: String, source: String) //TODO: show json parse error details
  case DeserializationFailure(message: String)
  case ParsingError(result: DecodeError)
  
  static func failure(_ response: HTTPURLResponse) -> HTTPResponseError
  {
    let statusCode = response.httpStatusCode
    return .Failure(statusCode: statusCode, description: statusCode.localizedDescription)
  }
}
