//
//  NetworkOperation.swift
//  VSLAutomation-swift
//
//  Created by Batman on 13/02/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit

enum JSONobjecttype : String {
    case JSONarray = "Json is kind of Array"
    case JSONdictionary = "Json is kind of Dictionary"
    case JSONstring = "Json is kind of String"
    case JSONunidentified = "Json is kind of UFO!!"
}

enum RequestType : String {
    case POST = "POST"
    case GET  = "GET"
}

enum HTTPheaderField : String {
    case json  = "application/json"
    case xml   = "application/atom+xml"
    case xForm = "application/x-www-form-urlencoded"
}

let expiredAuthToken =  "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGl0eSI6MSwiaWF0IjoxNDg3NjUzNDg1LCJuYmYiOjE0ODc2NTM0ODUsImV4cCI6MTQ4NzY1NzA4NX0.bQm2czCj1iAn_Y-zwx6_vREkcGxogSOZS4lfTU2GVzA"


class NetworkOperation: NSObject {
    
    class func callWebserviceWith (requestModel : NetworkRequestModel, target:AnyObject, callBack:Selector)
    {
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        
        switch requestModel.requestType! as RequestType
        {
        case .POST:
            let responseModel = NetworkResponseModel()
            responseModel.url = requestModel.url!
            
            var request = URLRequest(url: URL(string: requestModel.url!)!)
            request.httpMethod = requestModel.requestType?.rawValue
            if requestModel.requestParam != nil {
              //  request.httpBody = Utility.convertDictionaryToString(inputDictionary: requestModel.requestParam!)?.data(using: .utf8)
            }
            
            request.timeoutInterval = 15.0
            request.setValue(requestModel.headerField?.rawValue, forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                // If any error
                guard error == nil else
                {
                    responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: requestModel.url)
                    responseModel.status = false
                    responseModel.responseData = nil
                    target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                    return
                }
                
                // If Response code != 200
                if let httpStatus = response as? HTTPURLResponse  // check for http errors
                {
                    switch httpStatus.statusCode {

                    case NetworkErrorCode.Success.rawValue:
                        if let mData = data {
                            responseModel.data = mData
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = nil
                                responseModel.status = true
                                responseModel.responseData = dataDictionary
                                
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            case .JSONarray:
                                let dataArray = jsonTuple.jsonValue as! Array <Any>
                                responseModel.error = nil
                                responseModel.status = true
                                responseModel.responseData = dataArray
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            case .JSONstring:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.UnidentifiedData, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                let dataString = jsonTuple.jsonValue as? String
                                print("Error : -----> \(httpStatus.statusCode)")
                                print("Error : -----> \(String(describing: dataString))")
                                break
                                
                            case .JSONunidentified:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.UnidentifiedData, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                print("Error : -----> \(String(describing: jsonTuple.jsonValue))")
                                break
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: nil, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                    case NetworkErrorCode.AuthDenied.rawValue :
                        print("Error : -----> \(NetworkErrorCode.AuthDenied.localizedDescription)")
                        if let mData = data {
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.AuthDenied, errorAPIurl: responseModel.url)
                                responseModel.responseData = dataDictionary
                                responseModel.status = false
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            default:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.AuthDenied, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: nil, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                break
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: nil, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                    case NetworkErrorCode.NotFound.rawValue :
                        print("Error : -----> \(NetworkErrorCode.NotFound.localizedDescription)")
                        if let mData = data {
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: responseModel.url)
                                responseModel.responseData = dataDictionary
                                responseModel.status = false
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            default:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                break
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: nil, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                    case NetworkErrorCode.ServerError.rawValue :
                        print("Error : -----> \(NetworkErrorCode.ServerError.localizedDescription)")
                        if let mData = data {
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.ServerError, errorAPIurl: responseModel.url)
                                responseModel.responseData = dataDictionary
                                responseModel.status = false
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            default:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                break
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                        
                    default:
                        responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                        responseModel.status = false
                        responseModel.responseData = nil
                        target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                        print("Error : -----> \(httpStatus.statusCode)")
                        break
                    }
                }
            })
            task.resume()
            break
            
        case .GET:
            let responseModel = NetworkResponseModel()
            responseModel.url = requestModel.url!
            
            // FIXME: - Validate properly
            var request = URLRequest(url: URL(string: requestModel.url!)!)
            request.httpMethod = requestModel.requestType?.rawValue
            request.timeoutInterval = 10.0
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                // If any error
                guard error == nil else
                {
                    responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: responseModel.url)
                    responseModel.status = false
                    responseModel.responseData = nil
                    target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                    return
                }
                
                // If Response code != 200
                if let httpStatus = response as? HTTPURLResponse  // check for http errors
                {
                    switch httpStatus.statusCode {
                    case NetworkErrorCode.Success.rawValue:
                        if let mData = data {
                            responseModel.data = mData
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = nil
                                responseModel.responseData = dataDictionary
                                responseModel.status = true
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            case .JSONarray:
                                let dataArray = jsonTuple.jsonValue as! Array <Any>
                                responseModel.error = nil
                                responseModel.responseData = dataArray
                                responseModel.status = true
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            case .JSONstring:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.UnidentifiedData, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                let dataString = jsonTuple.jsonValue as? String
                                print("Error : -----> \(httpStatus.statusCode)")
                                print("Error : -----> \(String(describing: dataString))")
                                break
                                
                            case .JSONunidentified:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.UnidentifiedData, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                print("Error : -----> \(String(describing: jsonTuple.jsonValue))")
                                break
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                        
                    case NetworkErrorCode.AuthDenied.rawValue :
                        print("Error : -----> \(NetworkErrorCode.AuthDenied.localizedDescription)")
                        if let mData = data {
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.AuthDenied, errorAPIurl: responseModel.url)
                                responseModel.responseData = dataDictionary
                                responseModel.status = false
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            default:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.UnidentifiedData, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                print("Error : -----> \(httpStatus.statusCode)")
                                break
                                
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                    case NetworkErrorCode.NotFound.rawValue :
                        print("Error : -----> \(NetworkErrorCode.NotFound.localizedDescription)")
                        if let mData = data {
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: responseModel.url)
                                responseModel.responseData = dataDictionary
                                responseModel.status = false
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            default:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.UnidentifiedData, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                break
                                
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                    case NetworkErrorCode.ServerError.rawValue :
                        print("Error : -----> \(NetworkErrorCode.ServerError.localizedDescription)")
                        if let mData = data {
                            let jsonTuple = NetworkOperation.checkJSONobjectType(data: mData)
                            switch (jsonTuple.jsonType)
                            {
                            case .JSONdictionary:
                                let dataDictionary = jsonTuple.jsonValue as? Dictionary <String, Any>
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.ServerError, errorAPIurl: responseModel.url)
                                responseModel.responseData = dataDictionary
                                responseModel.status = false
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                break
                                
                            default:
                                responseModel.error = NetworkError.init(errorType: NetworkErrorCode.NotFound, errorAPIurl: requestModel.url)
                                responseModel.status = false
                                responseModel.responseData = nil
                                target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                                print("Error : -----> \(httpStatus.statusCode)")
                                break
                            }
                        }
                        else {
                            responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                            responseModel.status = false
                            responseModel.responseData = nil
                            target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                            print("Error : -----> \(httpStatus.statusCode)")
                        }
                        break
                        
                    default:
                        responseModel.error = NetworkError.init(errorType: NetworkErrorCode.DataNil, errorAPIurl: requestModel.url)
                        responseModel.status = false
                        responseModel.responseData = nil
                        target.performSelector(onMainThread: callBack, with: responseModel, waitUntilDone: true)
                        print("Error : -----> \(httpStatus.statusCode)")
                        break
                    }
                }
            })
            task.resume()
            break
        }
    }
    
    class func checkJSONobjectType (data : Data?) -> (jsonType : JSONobjecttype, jsonValue : Any?) {
        let parsedData = try? JSONSerialization.jsonObject(with: data!, options: [])
        if parsedData != nil && parsedData is Array<Any>
        {
            return (JSONobjecttype.JSONarray ,parsedData as? Array<Any>)
        }
        else if parsedData != nil && parsedData is Dictionary <String, Any>
        {
            return (JSONobjecttype.JSONdictionary ,parsedData as? Dictionary <String, Any>)
        }
        else if parsedData != nil,  let utf8Text = String(data: data!, encoding: .utf8)
        {
            return (JSONobjecttype.JSONstring, utf8Text)
        }
        else {
            return (JSONobjecttype.JSONunidentified, "Unidentified")
        }
    }
    
    /*
     class func getAuthenticationToken () {
     let authRequestModel = NetworkOperationDataModel ()
     authRequestModel.APIurl = Constants.WebServices.SkyEURL.retriveAuthenticationTokenURL
     authRequestModel.httpMethod = .POST
     authRequestModel.requestParameters = Utility.fetchUserLoginCredential()
     NetworkOperation.callWebserviceWith(dataModel: authRequestModel, target: self, callBack: #selector(NetworkOperation.authenticationTokenCallback(responseModel:)))
     }
     
     class func authenticationTokenCallback (responseModel : NetworkOperationDataModel) {
     if let userInfoDict = responseModel.responseData as? Dictionary <String, Any> {
     print ("Is type of Dictionary ----> \(userInfoDict)")
     Utility.saveAuthenticationToken(userInfoDict)
     }
     }
     */
}


