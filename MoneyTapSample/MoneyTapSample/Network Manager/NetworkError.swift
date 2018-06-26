//
//  ErrorCode.swift
//  VSLAutomation-swift
//
//  Created by Batman on 13/02/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit

enum NetworkErrorCode: Int, Error {
    case Success = 200
    case AuthDenied  = 401
    case NotFound = 404
    case ServerError = 500
    
    case DataNil = 1000
    case UnidentifiedData = 1001
}

struct NetworkError {
    var mErrorType   : NetworkErrorCode?
    var mErrorAPIurl : String?
    var mErrorDescription : Dictionary <String, String>?
    
    init(errorType : NetworkErrorCode?, errorAPIurl : String?) {
        self.mErrorType        = errorType
        self.mErrorAPIurl      = errorAPIurl
    }
}
