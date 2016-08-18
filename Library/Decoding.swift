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

func decode<T: Decodable>(rootKey: String) -> (AnyObject) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  return { objectData in
    let decodable = objectData as! [String : AnyObject]
    let result: Decoded<T> = decode(decodable, rootKey: rootKey)
    
    return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
  }
}

func decode<T: Decodable>(objectData: AnyObject) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  let result: Decoded<T> = decode(objectData)
  return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
}

func decode<T: Decodable>(rootKey: String) -> (AnyObject) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  return { objectData in
    let decodable = objectData as! [String: AnyObject]
    let result: Decoded<[T]> = decode(decodable, rootKey: rootKey)
    
    return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
  }
}

func decode<T: Decodable>(objectData: AnyObject) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  let result: Decoded<[T]> = decode(objectData)
  return (transform <^> objectData <*> result) ?? Result(error: .Unknown)
}

private func transform<T: Decodable>(objectData: AnyObject) -> (Decoded<T>) -> Result<T, HTTPResponseError> where T == T.DecodedType
{
  return { result in
    switch result {
    case .success(let value):
      return Result(value)
    case .failure(let error):
      let description = error.description 
      return Result(error: .DecodingFailed(description: description, source: sourceStringFrom(object: objectData)))
    }
  }
}

private func transform<T: Decodable>(objectData: AnyObject) -> (Decoded<[T]>) -> Result<[T], HTTPResponseError> where T == T.DecodedType
{
  return { result in
    switch result {
    case .success(let value):
      return Result(value)
    case .failure(let error):
      let description = error.description 
      return Result(error: .DecodingFailed(description: description, source: sourceStringFrom(object: objectData)))
    }
  }
}
