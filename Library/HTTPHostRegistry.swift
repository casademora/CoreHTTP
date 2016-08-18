//
//  HTTPUtility.swift
//  GaugesAPI
//
//  Created by Saul Mora on 6/19/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation

struct HostRegistry
{
  private var collection: Set<HTTPHost> = Set()
  
  fileprivate init() {}
  
  func hostFor<Resource: HostedResource>(_ resource: Resource) -> HTTPHost?
  {
    return collection.filter { type(of: $0) == resource.HostType }.first
  }
  
  mutating func register<Host: HTTPHost>(_ host: Host)
  {
    collection.insert(host)
  }
  
  mutating func unregister<Host: HTTPHost>(_ host: Host)
  {
    collection.remove(host)
  }
}

var hostRegistry = HostRegistry()

public func configure<H: HTTPHost>(host: H)
{
  hostRegistry.register(host)
}


/// Utilities

func convertToQueryString(dictionary: [String: String]) -> String?
{
  guard !dictionary.isEmpty else {  return nil }
  
  return dictionary
    .map { "\($0)=\($1)" }
   .joined(separator: "&")
}

func log(message: String)
{
  print(message)
}

extension Int
{
  var seconds: TimeInterval
  {
    return TimeInterval(self)
  }
  
  var minutes: TimeInterval
  {
    return TimeInterval(self * 60)
  }
  
  var hours: TimeInterval
  {
    return minutes * 60
  }
  
  var days: TimeInterval
  {
    return hours * 24
  }
}
