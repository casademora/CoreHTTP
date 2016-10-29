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

//public enum HTTPRequestError: HTTPResourceError
//{
//  case unknown
//  case hostForRequestNotFound
//  case hostNotSpecified
//  case hostBaseURLInvalid
//  
//  case unableToBuildRequest(path: String, queryParameters: [String: String])
//}

public enum HTTPResponseError: HTTPResourceError
{
  case unknown
  case cancelled
  case noResponse

  case invalidResponseType
  case hostNotSpecified
  case hostBaseURLInvalid
  case resourceRequestAgainstIncorrectHost(resourceType: String, hostType: String)
  case unableToBuildRequest(path: String, queryParameters: [String: String])
  
  case unexpectedHTTPStatus(statusCode: HTTPStatusCode, description: String)
  
  case decodingFailure(description: String, source: String)
  case deserializationFailure(message: String)
  
  static func responseFailure(_ response: HTTPURLResponse) -> HTTPResponseError
  {
    let statusCode = response.httpStatusCode
    return .unexpectedHTTPStatus(statusCode: statusCode, description: statusCode.localizedDescription)
  }
}

//public enum HTTPResponseParseError: HTTPResourceError
//{
//  case invalidResponseType
//  case decodingFailure(description: String, source: String)
//  case deserializationFailure(message: String) 
//}
//

