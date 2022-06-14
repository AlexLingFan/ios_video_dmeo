import Foundation
import UIKit

/// 资源文件
let Alex_SOURCE_BUNDLE = Bundle.init(path: Bundle.main.path(forResource: "AlexPlayer", ofType: "bundle")! + "/Icons")

/// 屏幕宽度
let Alex_SCREEN_WIDTH = UIScreen.main.bounds.size.width

/// 屏幕高度
let Alex_SCREEN_HEIGHT = UIScreen.main.bounds.size.height

/// 是否为X系列手机
var Alex_IS_IPHONEX: Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return false
    }
    
    let size = UIScreen.main.bounds.size
    let notchValue: Int = Int(size.width/size.height * 100)
    
    if 216 == notchValue || 46 == notchValue {
        return true
    }
    
    guard #available(iOS 11.0, *) else {
        return false
    }
    
    if let bottomHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
        return bottomHeight > 30
    }
    
    return UIApplication.shared.windows[0].safeAreaInsets.bottom > 30
}
