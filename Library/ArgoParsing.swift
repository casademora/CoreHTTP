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
