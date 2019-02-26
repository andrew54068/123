//
//  ViewController.swift
//  PopoverDemo
//
//  Created by kidnapper on 2019/2/26.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import mLayout

class ViewController: UIViewController {

    @IBOutlet weak var testButton: UIButton!
    
    @IBOutlet weak var userGuideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userGuideButton.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        userGuideButton.setTitleColor(.red, for: .highlighted)
        
        testButton.addTarget(self, action: #selector(showAlert(_:)), for: .touchUpInside)
    }
    
    @objc func showAlert(_ sender: UIButton) {
        vc.dismiss(animated: false, completion: nil)
        let alert: UIAlertController = UIAlertController(title: "alert", message: "this is me", preferredStyle: .alert)
        let action = UIAlertAction(title: "確認", style: .destructive, handler: nil)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    let vc: UserGuideVC = UserGuideVC(type: .discussion)
    
    @objc func didTap(_ sender: UIButton) {
        
        let popVC: UIPopoverPresentationController? = vc.popoverPresentationController
        
        func recusive(view: UIView) -> [UIView] {
            if view.subviews != [] {
                var array: [UIView] = []
                array = view.subviews.reduce(array) { (result, innerView) -> [UIView] in
                    let a: [UIView] = result
                    return a + recusive(view: innerView)
                }
                return array + [view]
            }
            return [view]
        }
        
        // be able to click other view beside UserGuideVC
        popVC?.passthroughViews = recusive(view: UIApplication.shared.keyWindow!)
        
        popVC?.sourceView = userGuideButton
        popVC?.sourceRect = CGRect(x: 0,
                                   y: 5,
                                   width: userGuideButton.bounds.width,
                                   height: userGuideButton.bounds.height)
        present(vc, animated: true, completion: nil)
    }

    class testTransition: NSObject, UIViewControllerTransitioningDelegate {
    
        func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return testTransitioning()
        }
    
    }
    
    class testTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 5
        }
    
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromView: UIView = transitionContext.view(forKey: .from),
                let toView: UIView = transitionContext.view(forKey: .to) else {
                    transitionContext.completeTransition(false)
                    return
            }
            let containerView: UIView = transitionContext.containerView
            containerView.addSubview(toView)
            containerView.backgroundColor = .red
    
            containerView.backgroundColor = .clear
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                fromView.alpha = 0.5
                toView.alpha = 0.7
            }, completion: { _ in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    
    }

}

enum UserGuideType {
    
    case discussion
    case branchCategories
    
    func guideText() -> String {
        switch self {
        case .discussion:
            return "點選「育兒發現」看看最新專家好文喔"
        case .branchCategories:
            return "點選「分類」幫您輕鬆找商品喔"
        }
    }
}

class UserGuideVC: UIViewController {
    
    var type: UserGuideType = .branchCategories
    
    lazy var userGuideLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = self.type.guideText()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "iconClose"), for: .normal)
        button.addTarget(self, action: #selector(dismissUserGuide), for: .touchUpInside)
        return button
    }()
    
    init(type: UserGuideType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        
        // 15 stands for label to left
        // 14 stands for label and button
        // 16 stands for button width
        // 10 stands for button to right
        preferredContentSize = CGSize(width: userGuideLabel.intrinsicContentSize.width + 15 + 14 + 16 + 10,
                                      height: userGuideLabel.intrinsicContentSize.height + 10 + 10)
        // must set modalPresentationStyle then set popoverPresentationController porperties
        modalPresentationStyle = .popover
        
        popoverPresentationController?.backgroundColor = .darkSkyBlueTwo
        popoverPresentationController?.permittedArrowDirections = .up
        popoverPresentationController?.popoverBackgroundViewClass = nil
        popoverPresentationController?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = .darkSkyBlueTwo
        
        view.addSubview(userGuideLabel)
        userGuideLabel.mLay(.centerY, .equal, view)
        userGuideLabel.mLay(.leading, .equal, view, .leading, constant: 15)
        
        view.addSubview(cancelButton)
        cancelButton.mLay(.centerY, .equal, view)
        cancelButton.mLay(.trailing, .equal, view, .trailing, constant: -10)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let mirrorNinePatchView: UIView = UIApplication.shared.keyWindow?.subviews[safe: 1]?.subviews[safe: 1] {
            
            // remove the shadow behide user guide
            mirrorNinePatchView.isHidden = true
            
        }
    }
    
    @objc func dismissUserGuide() {
        dismiss(animated: true,
                completion: {
                    if let mirrorNinePatchView: UIView = UIApplication.shared.keyWindow?.subviews[safe: 1]?.subviews[safe: 1] {
                        mirrorNinePatchView.isHidden = false
                    }
        })
    }
    
}

extension UserGuideVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return (0 <= index && index < count) ? self[index] : nil
    }
}


extension UIColor {
    static let darkSkyBlueTwo: UIColor = UIColor(red: 74.0 / 255.0,
                                                 green: 144.0 / 255.0,
                                                 blue: 226.0 / 255.0,
                                                 alpha: 1.0)
}
