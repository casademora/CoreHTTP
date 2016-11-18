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
  
  func hostFor<R>(_ resource: R) -> HTTPHost?
  where R: HTTPResourceProtocol & HostedResource
  {
    return collection.filter { $0.canRequestResource(resource: resource) }.first
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

private(set) var hostRegistry = HostRegistry()

public func register<H: HTTPHost>(host: H)
{
  hostRegistry.register(host)
}

public func unregister<H: HTTPHost>(host: H)
{
  hostRegistry.unregister(host)
}

public protocol HostedResource
{
  var hostType: AnyClass { get }
}

