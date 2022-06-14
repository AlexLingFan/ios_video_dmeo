import Foundation

import UIKit

extension Notification.Name {
    static let AlexVideoCacheManagerDidUpdateProgress = Notification.Name("AlexVideoCacheManagerDidUpdateProgress")
    static let AlexVideoCacheManagerDidFinishCachingAVideo = Notification.Name("AlexVideoCacheManagerDidFinishCachingAVideo")
    static let AlexVideoCacheManagerDidFinishCachingAllVideos = Notification.Name("AlexVideoCacheManagerDidFinishCachingAllVideos")
}

class AlexVideoCacheManager: NSObject, URLSessionDownloadDelegate {

    static let shared = AlexVideoCacheManager()
    
    var session: URLSession!
    
    //正在进行的任务和其对应的缓存对象
    fileprivate var caches = [URLSessionDownloadTask : AlexMediaCacheLocation]()
    
    fileprivate var progress = [URLSessionDownloadTask : (written: Int, expected: Int)]()
    
    private override init() {
        super.init()
        
        let config = URLSessionConfiguration.background(withIdentifier: "VideoCacheManagerURLSession")
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        
    }
    
    /// 缓存记录，记录的是缓存视频的identifier
    private(set) var cacheList: [String] {
        
        get {
            
            if let array = (NSArray(contentsOfFile: AlexFileDirectory.VideoCache.cachesPlist) as? [String]) {
                return Array(Set(array))
            } else {
                return []
            }
        }
        
        set {
            
            let array = Array(Set(newValue))
            (array as NSArray).write(toFile: AlexFileDirectory.VideoCache.cachesPlist, atomically: true)
        }
    }
    
    var cachingURLList: [URL] {
        return caches.values.map { (cache) -> URL in
            cache.originalURL
        }
    }
    
    var isCaching: Bool {
        return !caches.isEmpty
    }
    
    func cacheVideos(with urls: [URL]) -> Bool {
        
        guard isCaching == false else {
            return false
        }
        
        for url in urls {
            let location = AlexDefaultVideoCacheLocation(remoteURL: url, mediaType: .video)
            let task = session.downloadTask(with: location.authenticatedURL)
            task.resume()
            caches[task] = location
        }
        
        return true

    }
    
    func cancel() {
        for task in caches.keys {
            task.cancel()
        }
        caches.removeAll()
    }
    
    //MARK: URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let cache = caches[downloadTask] else {
            return
        }
        
        if AlexMediaCryptor.endecryptFile(from: location, to: cache.storageURL) {
            cacheList.append(cache.identifier)
        }
        
        caches.removeValue(forKey: downloadTask)
        NotificationCenter.default.post(name: .AlexVideoCacheManagerDidFinishCachingAVideo, object: self, userInfo: ["videoCache": cache])
        
        if caches.isEmpty {
            NotificationCenter.default.post(name: .AlexVideoCacheManagerDidFinishCachingAllVideos, object: self)
            
            progress.removeAll()
        }
        
        
    }
    
    
    /* Sent periodically to notify the delegate of download progress. */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let cache = caches[downloadTask] else {
            return
        }
        
        progress[downloadTask] = (Int(totalBytesWritten), Int(totalBytesExpectedToWrite))
        
        
        var written = 0
        var expected = 0
        
        for tuple in progress.values {
            written += tuple.written
            expected += tuple.expected
        }
        
        if expected != 0 || progress.count < caches.count {
            let progress = Float(written) / Float(expected)
            NotificationCenter.default.post(name: .AlexVideoCacheManagerDidUpdateProgress, object: self, userInfo: ["progress": progress, "videoCache": cache])
        }
    }
    
    
    /* Sent when a download has been resumed. If a download failed with an
     * error, the -userInfo dictionary of the error will contain an
     * NSURLSessionDownloadTaskResumeData key, whose value is the resume
     * data.
     */
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        print(downloadTask)
        print(fileOffset, expectedTotalBytes)
    }

}
