//
//  NASAPhoto.swift
//  NASA Photo of the Day
//
//  Created by Saul Mora on 10/27/16.
//  Copyright © 2016 Magical Panda, LLC. All rights reserved.
//

import Argo
import Curry
import Runes
import CoreHTTP

struct Photo
{
  let title: String
  let explanation: String
  
  let copyright: String
  
  let hdURLString: String
  let URLString: String
  
  var url: URL?
  {
    return URL(string: URLString)
  }
  
  var hdURL: URL?
  {
    return URL(string: hdURLString)
  }
  
  let serviceVersion: String
  
  let mediaType: MediaType
  let date: Date
  
  enum MediaType: String
  {
    case unknown
    case image
  }
}

extension Photo: Decodable
{
  static func decode(_ json: JSON) -> Decoded<Photo>
  {
    let f = curry(Photo.init)
      <^> json <| "title"
      <*> json <| "explanation"
      <*> json <| "copyright"
      <*> json <| "hdurl"
      <*> json <| "url"
    return f
      <*> json <| "service_version"
      <*> json <| "media_type"
      <*> (json <| "date" >>- dateFrom("yyyy-mm-dd"))
  }
}

extension Photo.MediaType: Decodable
{
  static func decode(_ json: JSON) -> Decoded<Photo.MediaType>
  {
    switch json {
    case .string(let value):
      if let mediaType = Photo.MediaType(rawValue: value)
      {
        return .success(mediaType)
      }
      fallthrough
    default:
      return .failure(.custom("Unable to decode MediaType"))
    }
  }
}
