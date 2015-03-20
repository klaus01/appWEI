//
//  AlamofireExt.swift
//  appWEI
//
//  Created by kelei on 15/3/20.
//  Copyright (c) 2015年 kelei. All rights reserved.
//

import Foundation

public enum UploadValue {
    case STRING(String)
    case PNGFILE(NSData)
    case OTHERFILE(NSData, String)
}

func upload(URLString: String, parameters: Dictionary<String, UploadValue>) -> Request {
    // create url request to send
    var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString)!)
    mutableURLRequest.HTTPMethod = Method.POST.rawValue
    let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())"
    let contentType = "multipart/form-data;boundary=\(boundaryConstant)"
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    // create upload data to send
    let uploadData = NSMutableData()
    
    func appendStringData(name: String, data: String) {
        uploadData.appendData("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(data)".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    func appendFileData(name: String, fileName: String, mimeType: String, data: NSData) {
        uploadData.appendData("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: \(mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(data)
    }
    
    // add parameters
    for (key, value) in parameters {
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        switch value {
        case let .STRING(str):
            appendStringData(key, str)
        case let .PNGFILE(fileData):
            appendFileData(key, "\(key).png", "image/png", fileData)
        case let .OTHERFILE(fileData, extName):
            appendFileData(key, "\(key).\(extName)", "application/octet-stream", fileData)
        }
    }
    uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    // return Request
    return upload(ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
}
    