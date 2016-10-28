//
//  Decoding.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/26/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Runes
import Argo
import Result

func decode<T: Decodable>(rootKey: String) -> (Any) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  return { objectData in
    guard let decodable = objectData as? [String : Any] else { return Result(error: .invalidResponseType) }
    let result: Decoded<T> = decode(decodable, rootKey: rootKey)
    
    return (transform <^> objectData <*> result)
      ?? Result(error: .deserializationFailure(message: "Object Data \(objectData), rootKey: \(rootKey)"))
  }
}

func decode<T: Decodable>(objectData: Any) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  let result: Decoded<T> = decode(objectData)
  
  return (transform <^> objectData <*> result)
    ?? Result(error: .deserializationFailure(message: "Object Data \(objectData)"))
}

func decode<T: Decodable>(rootKey: String) -> (Any) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  return { objectData in
    guard let decodable = objectData as? [String : Any] else { return Result(error: .invalidResponseType) }
    let result: Decoded<[T]> = decode(decodable, rootKey: rootKey)
    
    return (transform <^> objectData <*> result)
      ?? Result(error: .deserializationFailure(message: "Object Data \(objectData), rootKey: \(rootKey)"))
  }
}

func decode<T: Decodable>(objectData: Any) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  let result: Decoded<[T]> = decode(objectData)
  return (transform <^> objectData <*> result)
    ?? Result(error: .deserializationFailure(message: "Object Data: \(objectData)"))
}

fileprivate func transform<T: Decodable>(objectData: Any) -> (Decoded<T>) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  return { result in
    switch result {
    case .success(let value):
      return Result(value)
    case .failure(let error):
      let description = error.description 
      return Result(error: .decodingFailure(description: description, source: sourceStringFrom(object: objectData)))
    }
  }
}

fileprivate func transform<T: Decodable>(objectData: Any) -> (Decoded<[T]>) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  return { result in
    switch result {
    case .success(let value):
      return Result(value)
    case .failure(let error):
      let description = error.description 
      return Result(error: .decodingFailure(description: description, source: sourceStringFrom(object: objectData)))
    }
  }
}
