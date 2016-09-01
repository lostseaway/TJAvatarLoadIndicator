//
//  TJAvatarLoadIndicator.swift
//  Pods
//
//  Created by LostSeaWay on 8/31/2559 BE.
//
//


import RxSwift
import SnapKit
import UIKit

@IBDesignable public class TJAvatarLoadIndicator: UIView {
    @IBInspectable public var degree: Double = 135
    @IBInspectable public var centerImage: UIImage?
    @IBInspectable public var badgeSizePercentage: Float = 0.4
    @IBInspectable public var loadingColor: UIColor = UIColor.yellowColor()
    @IBInspectable public var completedColor: UIColor = UIColor(red:0.14, green:0.67, blue:0.67, alpha:1.0)
    @IBInspectable public var borderWidth:CGFloat = 1.0
    
    private let centerImageView = UIImageView()
    private var state: LoadState = .LoadingState
    private let sBadgeView = UIView()
    private var isDoneLoading = Variable(false)
    private let disposebag = DisposeBag()
    private var isObserved = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        centerImageView.image = centerImage
        centerImageView.layer.borderWidth = borderWidth
        centerImageView.layer.cornerRadius = centerImageView.frame.height / 2
        centerImageView.clipsToBounds = true
        badgeImagePosition()
        sBadgeView.layer.cornerRadius = sBadgeView.frame.height / 2
    }
    
    func initView() {
        initCenterImage()
        initBadgeImage()
    }
    
    func initCenterImage() {
        addSubview(centerImageView)
        centerImageView.snp_makeConstraints { [unowned self] make in
            make.centerX.centerY.equalTo(self)
            make.width.height.equalTo(self).multipliedBy(0.8)
        }
        centerImageView.layer.borderColor = loadingColor.CGColor
    }
    
    func initBadgeImage() {
        addSubview(sBadgeView)
    }
    
    func badgeImagePosition() {
        sBadgeView.snp_makeConstraints { make in
            make.width.height.equalTo(centerImageView).multipliedBy(badgeSizePercentage)
            make.centerX.equalTo(centerImageView).offset( (centerImageView.bounds.width/2.0) * CGFloat(-cos(degree * (M_PI/180))) )
            make.centerY.equalTo(centerImageView).offset( (centerImageView.bounds.width/2.0) * CGFloat(-sin(degree * (M_PI/180))) )
        }
    }
    
    public func startLoading() {
        state = .LoadingState
        sBadgeView.backgroundColor = loadingColor
        centerImageView.layer.borderColor = loadingColor.CGColor
        isDoneLoading.value = false
        animateLoading()
    }
    
    func animateLoading() {
        switch state {
        case .LoadingState:
            animate({
                self.animateLoading()
            })
            return
        case .CompletedState:
            CATransaction.begin()
            CATransaction.setCompletionBlock({ [unowned self] in
                self.sBadgeView.backgroundColor = self.completedColor
                self.centerImageView.layer.borderColor = self.completedColor.CGColor
                self.isDoneLoading.value = true
                })
            
            let animation = CABasicAnimation(keyPath: "borderColor")
            animation.fromValue = loadingColor.CGColor
            animation.toValue = completedColor.CGColor
            animation.duration = 2
            animation.fillMode = kCAFillModeForwards
            centerImageView.layer.addAnimation(animation, forKey: "borderColor")
            
            let sAni = CABasicAnimation(keyPath: "backgroundColor")
            sAni.fromValue = loadingColor.CGColor
            sAni.toValue = completedColor.CGColor
            sAni.duration = 2
            sAni.repeatCount = 1
            sAni.fillMode = kCAFillModeForwards
            sAni.autoreverses = false
            
            sBadgeView.layer.addAnimation(sAni, forKey: "fillColor")
            CATransaction.commit()
            
            animate({ })
        }
    }
    
    public func completeLoading(onComplete:()->Void) {
        state = .CompletedState
        if !isObserved {
            isDoneLoading.asObservable().subscribeNext { isDone in
                if isDone {
                    onComplete()
                }
                }.addDisposableTo(disposebag)
            isObserved = true
        }
    }
    
    func animate(onComplete:()->Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            onComplete()
        })
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.fillMode = kCAFillModeForwards
        
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 0, 0.5, 1)
        let myPath = UIBezierPath(arcCenter: centerImageView.center, radius: centerImageView.bounds.width/2, startAngle: CGFloat(7*M_PI_4), endAngle: CGFloat((7*M_PI_4)+(2*M_PI)), clockwise: true).CGPath
        
        animation.path = myPath
        animation.repeatCount = 1
        animation.duration = 2.0
        
        sBadgeView.layer.addAnimation(animation, forKey: "orbit")
        CATransaction.commit()
    }
}

enum LoadState {
    case LoadingState
    case CompletedState
}