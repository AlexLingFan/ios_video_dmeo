import Foundation

protocol AlexMediaCacheDelegate: class {
    
    /// 缓存进度更新
    func cache(_ cache: AlexMediaCacheManager, progress: Float)
    
    /// 缓存开始
    func cacheDidStarted(_ cache: AlexMediaCacheManager)
    
    /// 缓存完成
    func cacheDidFinished(_ cache: AlexMediaCacheManager)
    
    /// 缓存失败
    func cacheDidFailed(_ cache: AlexMediaCacheManager, withError error: Error?)
}
