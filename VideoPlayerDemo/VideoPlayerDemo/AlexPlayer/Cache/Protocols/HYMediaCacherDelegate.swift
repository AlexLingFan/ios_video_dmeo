import Foundation

public protocol AlexMediaCacherDelegate: class {
    
    /// 缓存进度更新
    func cacher<LocationType>(_ cacher: AlexMediaCacher<LocationType>, cacheProgress progress: Float, of cache: AlexMediaCacheManager)
    
    /// 缓存开始
    func cacher<LocationType>(_ cacher: AlexMediaCacher<LocationType>, didStartCacheOf cache: AlexMediaCacheManager)
    
    /// 缓存完成
    func cacher<LocationType>(_ cacher: AlexMediaCacher<LocationType>, didFinishCacheOf cache: AlexMediaCacheManager)
    
    /// 缓存失败
    func cacher<LocationType>(_ cacher: AlexMediaCacher<LocationType>, didFailToCache cache: AlexMediaCacheManager)
}
