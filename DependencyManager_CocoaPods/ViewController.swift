//
//  ViewController.swift
//  DependencyManager_CocoaPods
//
//  Created by Kaichi Momose on 2018/01/08.
//  Copyright © 2018 Kaichi Momose. All rights reserved.
//

import UIKit

import UIKit
import RxSwift
import RxGesture

class ViewController: UIViewController {
    @IBOutlet weak var container:UIImageView!
    let disposeBag = DisposeBag()
    var startPoint = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initPanObserver()
        self.initLongPressedObserver()
    }
    
    // to draw
    func initPanObserver(){
        let observer = self.container.rx.panGesture().share(replay: 1)
        observer
            .when(.began)
            .asLocation()
            .subscribe(onNext: { [unowned self] location in
                self.startPoint = location
            }).disposed(by: self.disposeBag)
        observer
            .when(.changed)
            .asLocation()
            .subscribe(onNext: { [unowned self] location in
                self.drawLine(fromPoint: self.startPoint, toPoint: location)
                self.startPoint = location
            }).disposed(by: self.disposeBag)
    }
    
    // to erase all
    func initLongPressedObserver(){
        let observer = self.container.rx.longPressGesture().share(replay: 1)
        observer
            .when(.began)
            .subscribe(onNext: {[unowned self] _ in
                self.container.image = nil
            }).disposed(by: self.disposeBag)
    }
    
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        self.container.image?.draw(in: CGRect.init(origin: CGPoint.zero, size: self.view.frame.size))
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setLineWidth(5)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setBlendMode(.normal)
        context.strokePath()
        self.container.image = UIGraphicsGetImageFromCurrentImageContext()
        self.container.alpha = 1.0
        UIGraphicsEndImageContext()
    }
}
