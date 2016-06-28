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

public enum HTTPResponseError: HTTPAPIError
{
  case Unknown
  case NoResponse
  case NoResponseData
//}
//
//public enum JSONParsingError: HTTPAPIError
//{
  case DecodingFailed(description: String, source: String) //TODO: show json parse error details
  case ParserError(error: NSError)
}
