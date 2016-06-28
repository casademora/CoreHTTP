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

func decode<T: Decodable where T == T.DecodedType>(rootKey: String) -> (AnyObject) -> Result<T, HTTPResponseError>
{
  return { objectData in
    let decodable = objectData as! [String : AnyObject]
    let result: Decoded<T> = decode(decodable, rootKey: rootKey)
    
    return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
  }
}

func decode<T: Decodable where T == T.DecodedType>(objectData: AnyObject) -> Result<T, HTTPResponseError>
{
  let result: Decoded<T> = decode(objectData)
  return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
}

func decode<T: Decodable where T == T.DecodedType>(rootKey: String) -> (AnyObject) -> Result<[T], HTTPResponseError>
{
  return { objectData in
    let decodable = objectData as! [String: AnyObject]
    let result: Decoded<[T]> = decode(decodable, rootKey: rootKey)
    
    return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
  }
}

func decode<T: Decodable where T == T.DecodedType>(objectData: AnyObject) -> Result<[T], HTTPResponseError>
{
  let result: Decoded<[T]> = decode(objectData)
  return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
}

private func transform<T: Decodable where T == T.DecodedType>(objectData: AnyObject) -> (Decoded<T>) -> Result<T, HTTPResponseError>
{
  return { result in
    switch result {
    case .Success(let value):
      return Result(value)
    case .Failure(let error):
      let description = error.description ?? "Unknown Error"
      return Result(error: .DecodingFailed(description: description, source: sourceStringFrom(object: objectData)))
    }
  }
}

private func transform<T: Decodable where T == T.DecodedType>(objectData: AnyObject) -> (Decoded<[T]>) -> Result<[T], HTTPResponseError>
{
  return { result in
    switch result {
    case .Success(let value):
      return Result(value)
    case .Failure(let error):
      let description = error.description ?? "Unknown Error"
      return Result(error: .DecodingFailed(description: description, source: sourceStringFrom(object: objectData)))
    }
  }
}
