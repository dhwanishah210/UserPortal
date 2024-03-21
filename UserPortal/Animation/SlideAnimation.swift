//
//  SlideAnimation.swift
//  FinalProject
//
//  Created by Dhwani Shah on 19/03/24.
//

import UIKit

class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        let screenWidth = UIScreen.main.bounds.width
        
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        if isPresenting {
            toVC.view.frame = finalFrame.offsetBy(dx: -screenWidth, dy: 0)
            containerView.addSubview(toVC.view)
        } else {
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        let animations = {
            if self.isPresenting {
                fromVC.view.frame = initialFrame.offsetBy(dx: screenWidth, dy: 0)
                toVC.view.frame = finalFrame
            } else {
                fromVC.view.frame = initialFrame.offsetBy(dx: -screenWidth, dy: 0)
                toVC.view.frame = finalFrame.offsetBy(dx: screenWidth, dy: 0)
            }
        }
        
        let completion: (Bool) -> Void = { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: animations,
                       completion: completion)
    }
}
