//
//  Parsing.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result
import Argo

public func parse<T: Decodable>(data: Data) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  let result = deserializeJSON(data: data)
  return result >>- decode
}

public func parse<T: Decodable>(rootKey: String) -> (Data) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  return { data in
    let result = deserializeJSON(data: data)
    return result >>- decode(rootKey: rootKey)
  }
}

public func parse<T: Decodable>(data: Data) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  return deserializeJSON(data: data)
    >>- decode
}

public func parse<T: Decodable>(rootKey: String) -> (Data) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  return { data in
    return deserializeJSON(data: data)
      >>- decode(rootKey: rootKey)
  }
}

func deserializeJSON(data: Data) -> Result<AnyObject, HTTPResponseError>
{
  do {
    let result = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
    return Result(result as AnyObject)
  }
  catch
  {
    log(level: .Error, message: "Unable to deserialize JSON: \(error)")
    return Result(error: .deserializationFailure(message: error.localizedDescription))
  }
}

func serializeJSON(object: AnyObject) -> Result<Data, HTTPResponseError>
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

private let unableToReadSourceMessage = "<<Unable to read source>>"

func sourceStringFrom(data: Data) -> String
{
  let source = String(data: data, encoding: String.Encoding.utf8) ?? unableToReadSourceMessage
  return source
}

func sourceStringFrom(object: AnyObject) -> String
{
  if let source = object as? CustomStringConvertible
  {
    return source.description
  }
  return unableToReadSourceMessage
}
