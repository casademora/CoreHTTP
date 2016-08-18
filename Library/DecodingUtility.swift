//
//  DecodingUtility.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/26/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Argo

extension URL: Decodable
{
  public static func decode(_ json: JSON) -> Decoded<URL>
  {
    if case .string(let value) = json, let url = URL(string: value)
    {
      return .success(url)
    }
    else
    {
      return .failure(.typeMismatch(expected: "URL", actual: json.description))
    }
  }
}

public func dateFrom(_ format: String) -> (String) -> Decoded<Date>
{
  let formatter = DateFormatter()
  formatter.dateFormat = format
  return { dateToFormat in
    if let date = formatter.date(from: dateToFormat) {
      return .success(date)
    }
    else{
      return .failure(.typeMismatch(expected: "Date", actual: dateToFormat))
    }
  }
}

public func stringFrom(_ date: Date, format: String) -> String
{
  let formatter = DateFormatter()
  formatter.dateFormat = format
  return formatter.string(from: date)
}

public func stringFrom(format: String) -> (Date) -> String
{
  let formatter = DateFormatter()
  formatter.dateFormat = format

  return { date in
    formatter.string(from: date)
  }
}
