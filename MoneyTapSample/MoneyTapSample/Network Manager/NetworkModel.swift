//
//  NetworkOperationDataModel.swift
//  VSLAutomation-swift
//
//  Created by Batman on 13/02/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit

class NetworkRequestModel: NSObject {
    var url          : String?
    var requestParam : [String : String]?
//    var authToken    : String?
    var requestType  : RequestType?
    var headerField  : HTTPheaderField?
}

class NetworkResponseModel: NSObject {
    var url          : String?
    var responseData : Any?
    var data         : Data?
    var status       : Bool?
    var error        : NetworkError?
}
