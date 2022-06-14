//
//  ViewController.swift
//  VideoPlayerDemo
//
//  Created by Alex.Lingjiahua on 2022/6/14.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var clickBtn: UIButton? = UIButton.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        baseUI()
    }


    func baseUI() {
        clickBtn = UIButton(frame: CGRect(x: 100, y: 300, width: self.view.frame.width - 200, height: 88))
        clickBtn?.backgroundColor = UIColor.gray
        clickBtn?.layer.cornerRadius = 12.0
        clickBtn?.addTarget(self, action: #selector(doAction), for: .touchUpInside)
        self.view.addSubview(clickBtn!)
    }
    
    /// do func
    @objc func doAction() {
        let vc = VideoViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
//        present(vc, animated: true)
       
    }
    
}

