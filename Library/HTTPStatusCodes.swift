//
//  HTTPStatusCodes.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

//https://en.wikipedia.org/wiki/List_of_HTTP_status_codes

public protocol HTTPStatusCodeProtocol: RawRepresentable, ExpressibleByIntegerLiteral
{
  var code: Int { get }
  var localizedDescription: String { get }
}

extension HTTPStatusCodeProtocol where RawValue == Int
{
  public var code: Int
  {
    return rawValue
  }
  
  public var localizedDescription: String
  {
    return HTTPURLResponse.localizedString(forStatusCode: code)
  }
}


extension HTTPURLResponse
{
  var httpStatusCode: HTTPStatusCode
  {
    return HTTPStatusCode.statusFor(code: statusCode)
  }
  
  var isSuccess: Bool
  {
    return httpStatusCode.isSuccess
  }
  
  var isInformational: Bool
  {
    return httpStatusCode.isInformational
  }
  
  var isRedirection: Bool
  {
    return httpStatusCode.isRedirection
  }
  
  var isClientError: Bool
  {
    return httpStatusCode.isClientError
  }

  var isServerError: Bool
  {
    return httpStatusCode.isServerError
  }
}

public enum HTTPStatusCode: Int, HTTPStatusCodeProtocol
{
  public init(integerLiteral value: Int)
  {
    self = HTTPStatusCode.statusFor(code: value)
  }
  
  static func statusFor(code: Int) -> HTTPStatusCode
  {
    return HTTPStatusCode(rawValue: code) ?? .Unknown
  }
  
  case Unknown = 0
  
  //informational
  case Continue = 100
  case SwitchingProtocols = 101
  case Processing = 102
  
  fileprivate static let informationalStatusCodes: [HTTPStatusCode] = [.Continue, .SwitchingProtocols, .Processing]
  public var isInformational: Bool
  {
    return HTTPStatusCode.informationalStatusCodes.contains(self)
  }
  
  //success
  case ok = 200
  case created = 201
  case accepted = 202
  case nonAuthoratativeInformation = 203
  case noContent = 204
  case resetContent = 205
  case partialContent = 206
  case multiStatus = 207
  case alreadyReported = 208
  case imUsed = 226
  
  fileprivate static let successStatusCodes: [HTTPStatusCode] = [.ok, .created, .accepted, .nonAuthoratativeInformation, .noContent, .resetContent, .partialContent, .multiStatus, .alreadyReported, .imUsed]
  public var isSuccess: Bool
  {
    return HTTPStatusCode.successStatusCodes.contains(self)
  }
  
  //redirection
  case multipleChoices = 300
  case movedPermanently = 301
  case found = 302
  case seeOther = 303
  case notModified = 304
  case useProxy = 305
  case switchProxy = 306
  case temporaryRedirect = 307
  case permanentRedirect = 308
  
  fileprivate static let redirectionStatusCodes: [HTTPStatusCode] = [.multipleChoices, .movedPermanently, .found, .seeOther, .notModified, .useProxy, .switchProxy, .temporaryRedirect, .permanentRedirect]
  public var isRedirection: Bool
  {
    return HTTPStatusCode.redirectionStatusCodes.contains(self)
  }
  
  //client error
  case badRequest = 400
  case unauthorized = 401
  case paymentRequired = 402
  case forbidden = 403
  case notFound = 404
  case methodNotAllowed = 405
  case notAcceptable = 406
  case proxyAuthenticationRequired = 407
  case requestTimeout = 408
  case conflict = 409
  case gone = 410
  case lengthRequired = 411
  case preconditionFailed = 412
  case payloadTooLarge = 413
  case uriTooLong = 414
  case unsupportedMediaType = 415
  case rangeNotStatisfiable = 416
  case expectationFailed = 417
  case imATeapot = 418
  case misdirectedRequest = 421
  case unprocessableEntity = 422
  case locked = 423
  case failedDependency = 424
  case upgradeRequired = 426
  case preconditionRequired = 428
  case tooManyRequests = 429
  case requestHeaderFieldsTooLarge = 431
  case unavailableForLegalReasons = 451
  
  private static let clientErrorStatusCodes: [HTTPStatusCode] = [.badRequest, .unauthorized, .paymentRequired, .forbidden, .notFound, .methodNotAllowed, .notAcceptable, .proxyAuthenticationRequired, .requestTimeout, .conflict, .gone, .lengthRequired, .preconditionFailed, .payloadTooLarge, .uriTooLong, .unsupportedMediaType, .rangeNotStatisfiable, .imATeapot, .misdirectedRequest, .unprocessableEntity, .locked, .failedDependency, .upgradeRequired, .preconditionRequired, .tooManyRequests, .requestHeaderFieldsTooLarge, .unavailableForLegalReasons]
  public var isClientError: Bool
  {
    return HTTPStatusCode.clientErrorStatusCodes.contains(self)
  }
  
  //server error
  case internalServerError = 500
  case notImplemented = 501
  case badGateway = 502
  case serviceUnavailable = 503
  case gatewayTimeout = 504
  case HTTPVersionNotSupported = 505
  case variantAlsoNegatiates = 506
  case insufficientStorage = 507
  case loopDetected = 508
  case notExtended = 510
  case networkAuthenticationRequired = 511
  
  fileprivate static let serverErrorStatusCodes: [HTTPStatusCode] = [.internalServerError, .notImplemented, .badGateway, .serviceUnavailable, .gatewayTimeout, .HTTPVersionNotSupported, .variantAlsoNegatiates, .insufficientStorage, .loopDetected, .notExtended, .networkAuthenticationRequired]
  public var isServerError: Bool
  {
    return HTTPStatusCode.serverErrorStatusCodes.contains(self)
  }
}

enum UnofficialStatusCode: Int, HTTPStatusCodeProtocol
{
  init(integerLiteral value: Int)
  {
    self = UnofficialStatusCode(rawValue: value) ?? .unknown
  }
  
  case unknown = 0
  case checkpoint = 103
  case enhaceYourCalm = 420
  case blockedByWindowsParentalControls = 450
  case invalidToken_Ersi = 498
  case tokenRequired_Ersi = 499
  //  case RequestHasBeenForbiddenByAntivirus = 499
  case bandwidthLimitExceeded = 509
  case siteIsFrozen = 530
  
  fileprivate static let allStatusCodes: [UnofficialStatusCode] = [.checkpoint, .enhaceYourCalm, .blockedByWindowsParentalControls, .invalidToken_Ersi, .tokenRequired_Ersi, .bandwidthLimitExceeded, .siteIsFrozen]
}

extension HTTPStatusCode
{
  public static func isUnofficial(statusCode: Int) -> Bool
  {
    return UnofficialStatusCode.allStatusCodes.map { $0.code }.contains(statusCode)
  }
}

enum InternetInformationServicesStatusCode: Int, HTTPStatusCodeProtocol
{
  init(integerLiteral value: Int)
  {
    self = InternetInformationServicesStatusCode(rawValue: value) ?? .unknown
  }

  case unknown = 0
  case loginTimeout = 440
  case retryWith = 449
  case redirect = 451
  
  fileprivate static let allStatusCodes: [InternetInformationServicesStatusCode] = [.loginTimeout,  .retryWith, .redirect]
}

extension HTTPStatusCode
{
  public static func isInternetInformationServices(statusCode: Int) -> Bool
  {
    return InternetInformationServicesStatusCode.allStatusCodes.map { $0.code }.contains(statusCode)
  }
}

enum NGinxStatusCode: Int, HTTPStatusCodeProtocol
{
  init(integerLiteral value: Int)
  {
    self = NGinxStatusCode(rawValue: value) ?? .unknown
  }

  case unknown = 0
  case noResponse = 444
  case SSLCertificateError = 495
  case SSLCertificateRequired = 496
  case HTTPRequestSentToHTTPSPort = 497
  case clientClosedRequest = 499
  
  fileprivate static let allStatusCodes: [NGinxStatusCode] = [.noResponse, .SSLCertificateError, .SSLCertificateRequired, .HTTPRequestSentToHTTPSPort, .clientClosedRequest]
}

extension HTTPStatusCode
{
  public static func isNGinx(statusCode: Int) -> Bool
  {
    return NGinxStatusCode.allStatusCodes.map { $0.code }.contains(statusCode)
  }
}

enum CloudFlareStatusCode: Int, HTTPStatusCodeProtocol
{
  init(integerLiteral value: Int)
  {
    self = CloudFlareStatusCode(rawValue: value) ?? .unknown
  }

  case unknown = 0
  case unknownError = 520
  case webServerIsDown = 521
  case connectionTimedOut = 522
  case originIsUnreachable = 523
  case aTimeoutOccured = 524
  case SSLHandshakeFailed = 525
  case invalidSSLCertificate = 526
  
  fileprivate static let allStatusCodes: [CloudFlareStatusCode] = [.unknownError, .webServerIsDown, .connectionTimedOut, .originIsUnreachable, .aTimeoutOccured, .SSLHandshakeFailed, .invalidSSLCertificate]
}

extension HTTPStatusCode
{
  public static func isCloudFlare(statusCode: Int) -> Bool
  {
    return CloudFlareStatusCode.allStatusCodes.map { $0.code }.contains(statusCode)
  }
}
