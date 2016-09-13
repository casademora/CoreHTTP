//
//  HTTPAPIError.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

public protocol HTTPResourceError: Error
{
}

public enum HTTPRequestError: HTTPResourceError
{
  case Unknown
}

public enum HTTPResponseError: HTTPResourceError
{
  case unknown
  case cancelled
  case noResponse
  case noResponseData
  case invalidResponseType
  case unexpectedHTTPStatus(statusCode: HTTPStatusCode, description: String)
  
  case decodingFailure(description: String, source: String) //TODO: show json parse error details
  case deserializationFailure(message: String)
  
  static func failure(_ response: HTTPURLResponse) -> HTTPResponseError
  {
    let statusCode = response.httpStatusCode
    return .unexpectedHTTPStatus(statusCode: statusCode, description: statusCode.localizedDescription)
  }
}
