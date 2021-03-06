import UIKit

class AlexMoreFunctionSpeedCollectionViewCell: UICollectionViewCell {
    
    /// 倍速展示
    var speedBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        createUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        contentView.addSubview(speedBtn)
        speedBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
