//
//  HTTPHostSessionDelegate.swift
//  CoreHTTP
//
//  Created by Saul Mora on 11/23/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

import Foundation

class HTTPHostSessionDelegate: NSObject
{
  private var pendingResponses: Set<AnyHTTPResponse> = []
  
  func register(pendingResponse: AnyHTTPResponse)
  {
    pendingResponses.insert(pendingResponse)
  }
  
  func response(for task: URLSessionTask) -> AnyHTTPResponse?
  {
    guard let setIndex = pendingResponses.index(where: { $0.hashValue == task.taskIdentifier }) else { return nil }
    return pendingResponses[setIndex]
  }
}

extension HTTPHostSessionDelegate: URLSessionDelegate
{

}

extension HTTPHostSessionDelegate: URLSessionTaskDelegate
{
  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
  {
    guard let response = response(for: task) as? URLSessionTaskDelegate else { return }
    response.urlSession?(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
  }
}

extension HTTPHostSessionDelegate: URLSessionDataDelegate
{

}

extension HTTPHostSessionDelegate: URLSessionDownloadDelegate
{
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
  {
//    guard let response = response(for: downloadTask) else { return }
    //response.progress.update()
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    
  }
  @available(iOS 7.0, *)
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
  {
    
  }
}
