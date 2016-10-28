//
//  NASAPhotoOfTheDay.swift
//  NASA Photo of the Day
//
//  Created by Saul Mora on 10/27/16.
//  Copyright © 2016 Magical Panda, LLC. All rights reserved.
//

import CoreHTTP
import Runes

class NASAAPODHost: HTTPHost
{
  init(apiKey: String)
  {
    let queryItem = URLQueryItem(name: "api_key", value: apiKey)
    super.init(baseURLString: "https://api.nasa.gov/planetary", configuration: .default, defaultQueryItems: [queryItem])
  }
}

class NASAAPODHTTPResource<T>: HTTPResource<T, AnyHTTPMethod>, HostedResource
{
  var HostType: AnyClass
  {
    return NASAAPODHost.self
  }
}



func astronomyPhotoOfTheDay(date: Date? = nil, includeHDPhoto: Bool = false) -> NASAAPODHTTPResource<Photo>
{
  var queryParameters: [String: String] = [:]
  queryParameters["date"] = date >>- stringFrom(format: "yyyy-mm-dd")
  queryParameters["hd"] = String(includeHDPhoto)
  return NASAAPODHTTPResource(path: "apod", method: .GET, queryParameters: queryParameters, parse: parse)
}


