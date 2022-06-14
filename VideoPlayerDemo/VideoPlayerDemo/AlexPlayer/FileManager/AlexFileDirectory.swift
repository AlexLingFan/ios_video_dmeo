import Foundation


/*
 应用内主要的文件类型有4种：音频、视频、文本、配置文件
 文件通常可以根据编号或者ID命名
 考虑文件夹内可能还会有第三方文件
 考虑文件夹不存在的可能性
 使用上语义的自然性
 */

struct AlexBaseFileDirectory {
    
    static let `default` = AlexBaseFileDirectory()
    
    private init() {
        try? FileManager.default.createDirectory(atPath: caches_video, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: playContinnue, withIntermediateDirectories: true, attributes: nil)
    }
    
    private static let bundleID: String = {
        if let id = Bundle.main.bundleIdentifier {
            return id
        } else {
            return "no.bundle.id"
        }
    }()
    
    //缓存的视频（可随时被系统删除，用户不能直接操作）
    let caches_video = NSHomeDirectory() + "/Library/Caches/\(bundleID)/Video"
    //音视频断点续播列表（可随时被系统删除，用户不能直接操作）
    let playContinnue = NSHomeDirectory() + "/Library/Caches/\(bundleID)/PlayContinnue"
}



/** 扩展命名规则：[名称][文件扩展名或文件内容类型（可选）][文件或文件夹]
 - 第一段：叙述路径表示的文件的基本功能。
 - 第二段：可选。如果文件有扩展名则为扩展名，如果扩展名不定或无扩展名则为文件的类型（如Audio，Video，Data，Text等），如果类型不定或难以叙述则留空。如果路径为文件夹路径，这段也为空
 - 第三段：用File或Directory表示文件或文件夹。
*/
struct AlexFileDirectory {
    
    static let shared = AlexBaseFileDirectory.default
    
    static func createDirectoryIfNeeded(at path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    static func pathsOfFiles(inDirectory directory: String) -> [String]? {
        return FileManager.default.subpaths(atPath: directory)?.map({ (subpath) -> String in
            return directory + "/" + subpath
        })
    }
}


extension AlexFileDirectory {
    
    struct VideoCache {
        
        static var videoDirectory: String {
            let path = AlexFileDirectory.shared.caches_video + "/VideoCache"
            AlexFileDirectory.createDirectoryIfNeeded(at: path)
            return path
        }
        
        static var cachesPlist: String {
            return videoDirectory + "/Caches.plist"
        }
        
    }
    
    
    struct PlayContinue {
        static var listDirectory: String {
            let path = AlexFileDirectory.shared.playContinnue
            AlexFileDirectory.createDirectoryIfNeeded(at: path)
            return path
        }
        
        static var listPlist: String {
            return listDirectory + "/PlayContinnue.plist"
        }
    }
}
