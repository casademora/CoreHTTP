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
    let generateCredentials: GenerateAuthenticationCredentialsFunction = { .QueryParameters("api_key", apiKey) }
    super.init(baseURLString: "https://api.nasa.gov/planetary", configuration: .default, authentication: generateCredentials)
  }
}

class NASAAPODHTTPResource<T>: HTTPResource<T, QueriableHTTPMethod>, HostedResource
{
  let hostType: AnyClass = NASAAPODHost.self
}


func astronomyPhotoOfTheDay(date: Date? = nil, includeHDPhoto: Bool = false) -> NASAAPODHTTPResource<Photo>
{
  var queryParameters: [String: String] = [:]
  queryParameters["date"] = date >>- stringFrom(format: "yyyy-mm-dd")
  queryParameters["hd"] = String(includeHDPhoto)
  return NASAAPODHTTPResource(path: "apod", method: .GET, queryParameters: queryParameters, parse: parse)
}


