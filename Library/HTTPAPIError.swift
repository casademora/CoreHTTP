//
//  HTTPAPIError.swift
//  GaugesAPI
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
  case NoResponse
  case NoResponseData
  case InvalidResponseType
  case GeneralFailure(statusCode: HTTPStatusCode, error: NSError?)
  
  case DecodingFailed(description: String, source: String) //TODO: show json parse error details
  case DeserializationFailure(message: String)
  case ParsingError(result: DecodeError)
  case Failure(error: NSError)
  
  static func failure(_ response: HTTPURLResponse) -> HTTPResponseError
  {
    return .GeneralFailure(statusCode: response.httpStatusCode, error: nil)
  }
}
