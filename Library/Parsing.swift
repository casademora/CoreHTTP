//
//  Parsing.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Result
import Argo
import Runes

public func parse<T: Decodable where T == T.DecodedType>(data: Data) -> Result<T, HTTPResponseError>
{
  let result = deserializeJSON(data: data)
  return result >>- decode
}

public func parse<T: Decodable where T == T.DecodedType>(rootKey: String) -> (Data) -> Result<T, HTTPResponseError>
{
  return { data in
    let result = deserializeJSON(data: data)
    return result >>- decode(rootKey: rootKey)
  }
}

public func parse<T: Decodable where T == T.DecodedType>(data: Data) -> Result<[T], HTTPResponseError>
{
  return deserializeJSON(data: data)
    >>- decode
}

public func parse<T: Decodable where T == T.DecodedType>(rootKey: String) -> (Data) -> Result<[T], HTTPResponseError>
{
  return { data in
    return deserializeJSON(data: data)
      >>- decode(rootKey: rootKey)
  }
}

func deserializeJSON(data: Data) -> Result<AnyObject, HTTPResponseError>
{
  do {
    let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
    return Result(result)
  }
  catch let error as NSError
  {
    log(message: "Unable to deserialize JSON: \(error)")
    return Result(error: .DeserializationFailure(message: error.localizedDescription))
  }
}

func serializeJSON(object: AnyObject) -> Result<Data, HTTPResponseError>
{
  do {
    let result = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0))
    return Result(result)
  }
  catch let error as NSError
  {
    log(message: "Unable to serialize JSON: \(error)")
    return Result(error: .DeserializationFailure(message: error.localizedDescription))
  }
}

func sourceStringFrom(data: Data) -> String
{
  let source = String(data: data, encoding: String.Encoding.utf8) ?? "<<Unable to read source>>"
  return source
}

func sourceStringFrom(object: AnyObject) -> String
{
  if let source = object as? CustomStringConvertible
  {
    return source.description
  }
  return "<<Unable to read source>>"
}
