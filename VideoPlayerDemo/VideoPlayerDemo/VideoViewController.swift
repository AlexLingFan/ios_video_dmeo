import UIKit
import SnapKit

class VideoViewController: UIViewController {
    
    
    /// 是否响应转动屏幕
    private var isRollEnable = true
    /// 等待缓存列表
    private var waitCacheUrlArray: [URL]?
    
    /// 当前选中序号
    private var currentPlayerConfigIndex: Int = 0
    /// 音视频播放列表
    private var playerConfigArray: [AlexPlayerCommonConfig]
        = [
//            AlexPlayerCommonConfig(title: "本地音频测试",
//                                 audioUrl: Bundle.main.path(forResource: "testSong", ofType: "mp3"),
//                                 placeHoldImg: "radio_bg_video"),
            AlexPlayerCommonConfig(title: "网络视频测试2",
                                 videoUrl: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
                                 needCache: false,
                                 placeHoldImg: "radio_bg_video"),
            AlexPlayerCommonConfig(title: "网络视频测试3",
                                 videoUrl: "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4",
                                 needCache: true,
                                 placeHoldImg: "radio_bg_video"),
            AlexPlayerCommonConfig(title: "本地视频测试",
                                 videoUrl: Bundle.main.path(forResource: "testMovie", ofType: "mp4"),
                                 placeHoldImg: "radio_bg_video"),
//            AlexPlayerCommonConfig(title: "网络音频测试",
//                                 audioUrl: "http://downsc.chinaz.net/Files/DownLoad/sound1/201906/11582.mp3",
//                                 needCache: true,
//                                 placeHoldImg: "radio_bg_video")
        ]
    
    /// AlexPlayer播放器
    private var videoView: AlexPlayerCommonView?
    
    /// 黑底
    private lazy var dartView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.isUserInteractionEnabled = true
        let hidTap = UITapGestureRecognizer(target: self, action: #selector(removeCacheView))
        view.addGestureRecognizer(hidTap)
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    /// 缓存列表
    private lazy var cacheView: AlexPlayerCacheListView = {
        let view = AlexPlayerCacheListView(frame: CGRect(x: 0, y: Alex_SCREEN_HEIGHT, width: Alex_SCREEN_WIDTH, height: 405))
        view.delegate = self
        return view
    }()
    
    /// 播放列表
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(PlayerListTableViewCell.self, forCellReuseIdentifier: "PlayerListTableViewCell")
        
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
        tableView.bounces = true
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        createUI()
        addDownloadObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoView?.dealToDisappear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func createUI() {
        
        let naviView = UIView()
        naviView.backgroundColor = .white
        view.addSubview(naviView)
        naviView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(Alex_IS_IPHONEX ? 88 : 64)
        }
        
        
        let returnBtn = UIButton()
        returnBtn.setImage(UIImage(named: "video_ic_back"), for: .normal)
        returnBtn.addTarget(self, action: #selector(returnBtnPressed), for: .touchUpInside)
        naviView.addSubview(returnBtn)
        returnBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.bottom.equalTo(-12)
            make.height.width.equalTo(18)
        }
        
        let cacheBtn = UIButton()
        cacheBtn.setImage(UIImage(named: "video_ic_download"), for: .normal)
        cacheBtn.addTarget(self, action: #selector(showCacheList), for: .touchUpInside)
        naviView.addSubview(cacheBtn)
        cacheBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(-14)
            make.centerY.equalTo(returnBtn)
            make.height.width.equalTo(24)
        }
        
        let playView = UIView()
        playView.backgroundColor = .white
        playView.clipsToBounds = true
        view.addSubview(playView)
        playView.snp.makeConstraints { (make) in
            make.top.equalTo(naviView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.width / 16 * 9)
        }
        
        videoView = AlexPlayerCommonView(playView)
        videoView?.delegate = self
        videoView?.updateCurrentPlayer(playerConfig: playerConfigArray[0])
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(playView.snp.bottom)
        }
        
        view.addSubview(dartView)
        dartView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    /** 添加下载监听*/
    private func addDownloadObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(cacheManagerDidFinishCachingAVideo(_:)), name: .AlexVideoCacheManagerDidFinishCachingAVideo, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cacheManagerDidFinishCachingAllVideos(_:)), name: .AlexVideoCacheManagerDidFinishCachingAllVideos, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cacheManagerDidUpdateProgress(_:)), name: .AlexVideoCacheManagerDidUpdateProgress, object: nil)
    }
    
    
    
    /** 删除缓存*/
    private func deleteCache(url: URL) {
        
        if videoView?.videoCacher.cacheList.contains(url.absoluteString.Alexmd5) == true {
            
            let location = AlexDefaultVideoCacheLocation(remoteURL: url, mediaType: .video)
            videoView?.videoCacher.removeCache(located: location)
            
            if let videoCacher = videoView?.videoCacher {
                cacheView.reloadCache(videoCacher: videoCacher)
            }
        }
    }
    
    //  是否支持自动转屏
    override var shouldAutorotate: Bool {
        return isRollEnable
    }
    
    // 支持哪些转屏方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    //        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    //            return .landscapeLeft
    //        }
    
    
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension VideoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerConfigArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerListTableViewCell", for: indexPath) as! PlayerListTableViewCell
        if playerConfigArray.count > indexPath.row {
            let playerConfig = playerConfigArray[indexPath.row]
            cell.titleLab.text = playerConfig.title
        }
        cell.titleLab.textColor = indexPath.row == currentPlayerConfigIndex ? .red : .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if playerConfigArray.count > indexPath.row && indexPath.row != currentPlayerConfigIndex {
            let playerConfig = playerConfigArray[indexPath.row]
            videoView?.updateCurrentPlayer(playerConfig: playerConfig)
            currentPlayerConfigIndex = indexPath.row
            tableView.reloadData()
        }
    }
}

//MARK: Event and Notification
extension VideoViewController {
    
    /** 展示缓存列表*/
    @objc private func showCacheList() {
        if let videoCacher = videoView?.videoCacher {
            cacheView.configView(cacheList: playerConfigArray, videoCacher: videoCacher)
            UIApplication.shared.keyWindow?.addSubview(cacheView)
            
            dartView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.dartView.alpha = 0.5
                self.cacheView.frame = CGRect(x: 0, y: Alex_SCREEN_HEIGHT - 405, width: Alex_SCREEN_WIDTH, height: 405)
            })
        }
    }
    
    /** 隐藏缓存列表*/
    @objc private func removeCacheView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dartView.alpha = 0
            self.cacheView.frame = CGRect(x: 0, y: Alex_SCREEN_HEIGHT, width: Alex_SCREEN_WIDTH, height: 405)
        }) { (success) in
            self.dartView.isHidden = true
            self.cacheView.removeFromSuperview()
        }
    }
    
    /** 返回*/
    @objc private func returnBtnPressed() {
        dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    /** 缓存列表单个视频下载完成*/
    @objc func cacheManagerDidFinishCachingAVideo(_ notification: Notification) {
        print("下载完成")
        if let cache = notification.userInfo?["videoCache"] as? AlexMediaCacheLocation {
            DispatchQueue.main.async {
                self.cacheView.finishVideoCache(cacheIdentifier: cache.identifier)
                if let videoCacher = self.videoView?.videoCacher {
                    self.cacheView.reloadCache(videoCacher: videoCacher)
                }
            }
        }
        
    }
    
    /** 缓存列表全部选中视频下载完成*/
    @objc func cacheManagerDidFinishCachingAllVideos(_ notification: Notification) {
        print("全部下载完成")
        DispatchQueue.main.async {
            if let videoCacher = self.videoView?.videoCacher {
                //                self.cacheView.finishAllVideoCache()
                self.cacheView.reloadCache(videoCacher: videoCacher)
            }
        }
    }
    
    /** 缓存列表视频下载进度*/
    @objc func cacheManagerDidUpdateProgress(_ notification: Notification) {
        
        if let cache = notification.userInfo?["videoCache"] as? AlexMediaCacheLocation, let progress = (notification.userInfo?["progress"] as? NSNumber)?.floatValue {
            print("当前缓存进度：\(Int(progress * 100))%")
            DispatchQueue.main.async {
                self.cacheView.updateCacheProgress(cacheIdentifier: cache.identifier, progress: CGFloat(progress))
            }
        }
    }
}

//MARK: AlexPlayerCommonViewDelegate
extension VideoViewController: AlexPlayerCommonViewDelegate {
    /** 全屏状态改变*/
    func changeFullScreen(isFull: Bool) {
        print(isFull ? "全屏" : "退出全屏")
    }
    
    /** 全屏锁定*/
    func fullScreenLock(isLock: Bool) {
        isRollEnable = !isLock
    }
    
    /** 展示控制台*/
    func showControlPanel() {
        print("展示控制台")
    }
    
    /** 隐藏控制台*/
    func hideControlPanel() {
        print("隐藏控制台")
    }
    
    /** 流量提醒*/
    func flowRemind() {
        print("正在使用流量")
    }
    
    /** 开始播放*/
    func startPlayer() {
        print("开始播放")
    }
    
    /** 播放暂停*/
    func pausePlayer() {
        print("暂停播放")
    }
    
    /** 结束播放*/
    func stopPlayer() {
        print("结束播放")
    }
    
    /** 缓存开始*/
    func startCache() {
        print("缓存开始")
    }
    
    /** 缓存进行中*/
    func inCaching(progress: Float) {
        print("缓存进度更新：\(progress)")
    }
    
    /** 缓存完成*/
    func completeCache() {
        print("缓存完成")
    }
    
    /** 缓存失败*/
    func faildCache() {
        print("缓存失败")
    }
}

//MARK: AlexPlayerCacheListViewDelegate
extension VideoViewController: AlexPlayerCacheListViewDelegate {
    /** 确认删除缓存*/
    func alertToDeleteVideoCache(url: URL) {
        let alert = UIAlertController(title: "确认删除缓存", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "删除", style: .default, handler: { (action) -> Void in
            self.deleteCache(url: url)
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /** 删除缓存*/
    func deleteVideoCache(urls: [URL]) {
        
        let alert = UIAlertController(title: "确认删除缓存", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "删除", style: .default, handler: { (action) -> Void in
            for url in urls {
                self.deleteCache(url: url)
            }
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    /** 开始缓存*/
    func startVideoCache() {
        
    }
}
