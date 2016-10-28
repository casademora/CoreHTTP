//
//  JSONSerialization.swift
//  CoreHTTP
//
//  Created by Saul Mora on 10/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result

func deserializeJSON(data: Data) -> Result<Any, HTTPResponseError>
{
  do {
    let result = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
    return Result(result)
  }
  catch
  {
    log(level: .Error, message: "Unable to deserialize JSON: \(error)")
    return Result(error: .deserializationFailure(message: error.localizedDescription))
  }
}

func serializeJSON(object: Any) -> Result<Data, HTTPResponseError>
{
  do {
    let result = try JSONSerialization.data(withJSONObject: object, options: .init(rawValue: 0))
    return Result(result)
  }
  catch
  {
    log(level: .Error, message: "Unable to serialize JSON: \(error)")
    return Result(error: .deserializationFailure(message: error.localizedDescription))
  }
}

fileprivate let unableToReadSourceMessage = "<<Unable to read source>>"

func sourceStringFrom(data: Data) -> String
{
  let source = String(data: data, encoding: String.Encoding.utf8) ?? unableToReadSourceMessage
  return source
}

func sourceStringFrom(object: Any) -> String
{
  if let source = object as? CustomStringConvertible
  {
    return source.description
  }
  return unableToReadSourceMessage
}
