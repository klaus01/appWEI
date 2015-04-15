//
//  ImageDownloader.swift
//  Kingfisher
//
//  Created by Wei Wang on 15/4/6.
//  Copyright (c) 2015年 Wei Wang. All rights reserved.
//

import Foundation
import UIKit

public typealias ImageDownloaderProgressBlock = DownloadProgressBlock
public typealias ImageDownloaderCompletionHandler = CompletionHandler

public typealias RetrieveImageDownloadTask = NSURLSessionDataTask

private let downloaderBarrierName = "com.onevcat.Kingfisher.ImageDownloader.Barrier"
private let imageProcessQueueName = "com.onevcat.Kingfisher.ImageDownloader.Process"
private let instance = ImageDownloader()

public class ImageDownloader: NSObject {
    
    class ImageFetchLoad {
        var callbacks = [CallbackPair]()
        var responseData = NSMutableData()
        var shouldDecode = false
    }
    
    // MARK: - Public property
    /// The duration before the download is timeout. Default is 15 seconds.
    public var downloadTimeout: NSTimeInterval = 15.0
    
    // MARK: - Internal property
    let barrierQueue = dispatch_queue_create(downloaderBarrierName, DISPATCH_QUEUE_CONCURRENT)
    let processQueue = dispatch_queue_create(imageProcessQueueName, DISPATCH_QUEUE_CONCURRENT)
    
    typealias CallbackPair = (progressBlock: ImageDownloaderProgressBlock?, completionHander: ImageDownloaderCompletionHandler?)
    
    var fetchLoads = [NSURL: ImageFetchLoad]()
    
    // MARK: - Public method
    /// The default downloader.
    public class var defaultDownloader: ImageDownloader {
        return instance
    }
}

// MARK: - Download method
public extension ImageDownloader {
    /**
    Download an image with a URL.
    
    :param: URL               Target URL.
    :param: progressBlock     Called when the download progress updated.
    :param: completionHandler Called when the download progress finishes.
    */
    public func downloadImageWithURL(URL: NSURL,
        progressBlock: ImageDownloaderProgressBlock?,
        completionHandler: ImageDownloaderCompletionHandler?)
    {
        downloadImageWithURL(URL, options: KingfisherManager.OptionsNone, progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    /**
    Download an image with a URL and option.
    
    :param: URL               Target URL.
    :param: options           The options could control download behavior. See `KingfisherManager.Options`
    :param: progressBlock     Called when the download progress updated.
    :param: completionHandler Called when the download progress finishes.
    */
    public func downloadImageWithURL(URL: NSURL,
        options: KingfisherManager.Options,
        progressBlock: ImageDownloaderProgressBlock?,
        completionHandler: ImageDownloaderCompletionHandler?)
    {
        downloadImageWithURL(URL,
            retrieveImagetask: nil,
                      options: options,
                progressBlock: progressBlock,
            completionHandler: completionHandler)
    }
    
    internal func downloadImageWithURL(URL: NSURL,
                       retrieveImagetask: RetrieveImageTask?,
                                 options: KingfisherManager.Options,
                           progressBlock: ImageDownloaderProgressBlock?,
                       completionHandler: ImageDownloaderCompletionHandler?)
    {
        setupProgressBlock(progressBlock, completionHandler: completionHandler, forURL: URL) {(session, fetchLoad) -> Void in
            let timeout = self.downloadTimeout == 0.0 ? 15.0 : self.downloadTimeout
            let request = NSMutableURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: timeout)
            request.HTTPShouldUsePipelining = true
            let task = session.dataTaskWithRequest(request)
            
            task.priority = options.lowPriority ? NSURLSessionTaskPriorityLow : NSURLSessionTaskPriorityDefault
            task.resume()
            
            fetchLoad.shouldDecode = options.shouldDecode
            
            retrieveImagetask?.downloadTask = task
        }
    }
    
    // A single key may have multiple callbacks. Only download once.
    internal func setupProgressBlock(progressBlock: ImageDownloaderProgressBlock?, completionHandler: ImageDownloaderCompletionHandler?, forURL URL: NSURL, started: ((NSURLSession, ImageFetchLoad) -> Void)) {

        dispatch_barrier_sync(barrierQueue, { () -> Void in

            var create = false
            var loadObjectForURL = self.fetchLoads[URL]
            if  loadObjectForURL == nil {
                create = true
                loadObjectForURL = ImageFetchLoad()
            }
            
            let callbackPair = (progressBlock: progressBlock, completionHander: completionHandler)
            loadObjectForURL!.callbacks.append(callbackPair)
            self.fetchLoads[URL] = loadObjectForURL!
            
            if create {
                let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue:NSOperationQueue.mainQueue())
                started(session, loadObjectForURL!)
            }
        })
    }
    
    func cleanForURL(URL: NSURL) {
        dispatch_barrier_sync(barrierQueue, { () -> Void in
            self.fetchLoads.removeValueForKey(URL)
            return
        })
    }
}

// MARK: - NSURLSessionTaskDelegate
extension ImageDownloader: NSURLSessionDataDelegate {
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        if let URL = dataTask.originalRequest.URL, callbackPairs = fetchLoads[URL]?.callbacks {
            for callbackPair in callbackPairs {
                callbackPair.progressBlock?(receivedSize: 0, totalSize: response.expectedContentLength)
            }
        }
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {

        if let URL = dataTask.originalRequest.URL, fetchLoad = fetchLoads[URL] {
            fetchLoad.responseData.appendData(data)
            for callbackPair in fetchLoad.callbacks {
                callbackPair.progressBlock?(receivedSize: Int64(fetchLoad.responseData.length), totalSize: dataTask.response!.expectedContentLength)
            }
        }
    }
    
    private func callbackWithImage(image: UIImage?, error: NSError?, imageURL: NSURL) {
        if let callbackPairs = self.fetchLoads[imageURL]?.callbacks {
            for callbackPair in callbackPairs {
                callbackPair.completionHander?(image: image, error: error, imageURL: imageURL)
            }
        }
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        let URL = task.originalRequest.URL!
        
        if let error = error { // Error happened
            callbackWithImage(nil, error: error, imageURL: URL)
        } else { //Download finished without error
            
            // We are on main queue when receiving this.
            dispatch_async(processQueue, { () -> Void in
                
                if let fetchLoad = self.fetchLoads[URL] {
                    if let image = UIImage(data: fetchLoad.responseData) {
                        if fetchLoad.shouldDecode {
                            self.callbackWithImage(image.kf_decodedImage(), error: nil, imageURL: URL)
                        } else {
                            self.callbackWithImage(image, error: nil, imageURL: URL)
                        }

                    } else {
                        self.callbackWithImage(nil, error: NSError(domain: KingfisherErrorDomain, code: KingfisherError.BadData.rawValue, userInfo: nil), imageURL: URL)
                    }
                } else {
                    self.callbackWithImage(nil, error: NSError(domain: KingfisherErrorDomain, code: KingfisherError.BadData.rawValue, userInfo: nil), imageURL: URL)
                }
                
                self.cleanForURL(URL)
            })
        }
    }

}
