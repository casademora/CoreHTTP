//
//  HTTPStatusCodes.swift
//  CoreHTTP
//
//  Created by Saul Mora on 6/28/16.
//  Copyright © 2016 Magical Panda Software. All rights reserved.
//

//https://en.wikipedia.org/wiki/List_of_HTTP_status_codes

public protocol HTTPStatusCodeProtocol
{
  var rawValue: Int { get }
  var code: Int { get }
  var localizedDescription: String { get }
}

extension HTTPStatusCodeProtocol
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
  static func statusFor(code: Int) -> HTTPStatusCode
  {
    return HTTPStatusCode(rawValue: code) ?? .Unknown
  }
  
  case Unknown = 0
  
  //informational
  case Continue = 100
  case SwitchingProtocols = 101
  case Processing = 102
  
  private static let informationalStatusCodes: [HTTPStatusCode] = [.Continue, .SwitchingProtocols, .Processing]
  public var isInformational: Bool
  {
    return HTTPStatusCode.informationalStatusCodes.contains(self)
  }
  
  //success
  case OK = 200
  case Created = 201
  case Accepted = 202
  case NonAuthoratativeInformation = 203
  case NoContent = 204
  case ResetContent = 205
  case PartialContent = 206
  case MultiStatus = 207
  case AlreadyReported = 208
  case IMUsed = 226
  
  private static let successStatusCodes: [HTTPStatusCode] = [.OK, .Created, .Accepted, .NonAuthoratativeInformation, .NoContent, .ResetContent, .PartialContent, .MultiStatus, .AlreadyReported, .IMUsed]
  public var isSuccess: Bool
  {
    return HTTPStatusCode.successStatusCodes.contains(self)
  }
  
  //redirection
  case MultipleChoices = 300
  case MovedPermanently = 301
  case Found = 302
  case SeeOther = 303
  case NotModified = 304
  case UseProxy = 305
  case SwitchProxy = 306
  case TemporaryRedirect = 307
  case PermanentRedirect = 308
  
  private static let redirectionStatusCodes: [HTTPStatusCode] = [.MultipleChoices, .MovedPermanently, .Found, .SeeOther, .NotModified, .UseProxy, .SwitchProxy, .TemporaryRedirect, .PermanentRedirect]
  public var isRedirection: Bool
  {
    return HTTPStatusCode.redirectionStatusCodes.contains(self)
  }
  
  //client error
  case BadRequest = 400
  case Unauthorized = 401
  case PaymentRequired = 402
  case Forbidden = 403
  case NotFound = 404
  case MethodNotAllowed = 405
  case NotAcceptable = 406
  case ProxyAuthenticationRequired = 407
  case RequestTimeout = 408
  case Conflict = 409
  case Gone = 410
  case LengthRequired = 411
  case PreconditionFailed = 412
  case PayloadTooLarge = 413
  case URITooLong = 414
  case UnsupportedMediaType = 415
  case RangeNotStatisfiable = 416
  case ExpectationFailed = 417
  case ImATeapot = 418
  case MisdirectedRequest = 421
  case UnprocessableEntity = 422
  case Locked = 423
  case FailedDependency = 424
  case UpgradeRequired = 426
  case PreconditionRequired = 428
  case TooManyRequests = 429
  case RequestHeaderFieldsTooLarge = 431
  case UnavailableForLegalReasons = 451
  
  private static let clientErrorStatusCodes: [HTTPStatusCode] = [.BadRequest, .Unauthorized, .PaymentRequired, .Forbidden, .NotFound, .MethodNotAllowed, .NotAcceptable, .ProxyAuthenticationRequired, .RequestTimeout, .Conflict, .Gone, .LengthRequired, .PreconditionFailed, .PayloadTooLarge, .URITooLong, .UnsupportedMediaType, .RangeNotStatisfiable, .ImATeapot, .MisdirectedRequest, .UnprocessableEntity, .Locked, .FailedDependency, .UpgradeRequired, .PreconditionRequired, .TooManyRequests, .RequestHeaderFieldsTooLarge, .UnavailableForLegalReasons]
  public var isClientError: Bool
  {
    return HTTPStatusCode.clientErrorStatusCodes.contains(self)
  }
  
  //server error
  case InternalServerError = 500
  case NotImplemented = 501
  case BadGateway = 502
  case ServiceUnavailable = 503
  case GatewayTimeout = 504
  case HTTPVersionNotSupported = 505
  case VariantAlsoNegatiates = 506
  case InsufficientStorage = 507
  case LoopDetected = 508
  case NotExtended = 510
  case NetworkAuthenticationRequired = 511
  
  private static let serverErrorStatusCodes: [HTTPStatusCode] = [.InternalServerError, .NotImplemented, .BadGateway, .ServiceUnavailable, .GatewayTimeout, .HTTPVersionNotSupported, .VariantAlsoNegatiates, .InsufficientStorage, .LoopDetected, .NotExtended, .NetworkAuthenticationRequired]
  public var isServerError: Bool
  {
    return HTTPStatusCode.serverErrorStatusCodes.contains(self)
  }
}

enum UnofficialStatusCode: Int, HTTPStatusCodeProtocol
{
  case Checkpoint = 103
  case EnhaceYourCalm = 420
  case BlockedByWindowsParentalControls = 450
  case InvalidToken_Ersi = 498
  case TokenRequired_Ersi = 499
  //  case RequestHasBeenForbiddenByAntivirus = 499
  case BandwidthLimitExceeded = 509
  case SiteIsFrozen = 530
  
  static let allStatusCodes: [UnofficialStatusCode] = [.Checkpoint, .EnhaceYourCalm, .BlockedByWindowsParentalControls, .InvalidToken_Ersi, .TokenRequired_Ersi, .BandwidthLimitExceeded, .SiteIsFrozen]
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
  case LoginTimeout = 440
  case RetryWith = 449
  case Redirect = 451
  
  private static let allStatusCodes: [InternetInformationServicesStatusCode] = [.LoginTimeout,  .RetryWith, .Redirect]
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
  case NoResponse = 444
  case SSLCertificateError = 495
  case SSLCertificateRequired = 496
  case HTTPRequestSentToHTTPSPort = 497
  case ClientClosedRequest = 499
  
  private static let allStatusCodes: [NGinxStatusCode] = [.NoResponse, .SSLCertificateError, .SSLCertificateRequired, .HTTPRequestSentToHTTPSPort, .ClientClosedRequest]
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
  case UnknownError = 520
  case WebServerIsDown = 521
  case ConnectionTimedOut = 522
  case OriginIsUnreachable = 523
  case ATimeoutOccured = 524
  case SSLHandshakeFailed = 525
  case InvalidSSLCertificate = 526
  
  private static let allStatusCodes: [CloudFlareStatusCode] = [.UnknownError, .WebServerIsDown, .ConnectionTimedOut, .OriginIsUnreachable, .ATimeoutOccured, .SSLHandshakeFailed, .InvalidSSLCertificate]
}

extension HTTPStatusCode
{
  public static func isCloudFlare(statusCode: Int) -> Bool
  {
    return CloudFlareStatusCode.allStatusCodes.map { $0.code }.contains(statusCode)
  }
}
