//
//  SemiModalViewController.swift
//  LightsOut
//
//  Created by Essence K on 21.12.2021.
//

import UIKit

class SemiModalViewController<ViewController>: UIViewController,
    UIViewControllerTransitioningDelegate
where ViewController: UIViewController {

    private lazy var gripView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 2
        return view
    }()
    private let contentView = UIView()

    let controller: () -> ViewController
    let usePreferredContentSize: Bool
    let isGripViewHidden: Bool

    init(
        usePreferredContentSize: Bool = true,
        isGripViewHidden: Bool = false,
        controller: @escaping () -> ViewController
    ) {
        self.controller = controller
        self.usePreferredContentSize = usePreferredContentSize
        self.isGripViewHidden = isGripViewHidden

        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        if !isGripViewHidden {
            setupGripView()
        }
        setupContentView()

        calculatePreferredContentSize()
    }

    private func setupGripView() {
        contentView.addSubview(gripView, constraints: [
            gripView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            gripView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gripView.widthAnchor.constraint(equalToConstant: 48),
            gripView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func setupContentView() {
        let viewController = controller()
        viewController.willMove(toParent: self)
        addChild(viewController)

        contentView.addSubview(viewController.view, constraints: [
            viewController.view.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: isGripViewHidden ? 0 : 16
            ),
            viewController.view.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            viewController.view.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            viewController.view.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            )
        ])
        viewController.didMove(toParent: self)

        contentView.backgroundColor = viewController.view.backgroundColor
        viewController.view.layer.cornerRadius = 20
        contentView.layer.cornerRadius = 20
        self.view = contentView
    }

    private func calculatePreferredContentSize() {
        let width = presentingViewController?.view.window?.bounds.size.width ?? UIScreen.main.bounds.width
        let contentSize = view.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .defaultLow)

        self.preferredContentSize = contentSize
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func systemLayoutFittingSizeDidChange(forChildContentContainer container: UIContentContainer) {
        calculatePreferredContentSize()
    }

    // MARK: UIViewControllerTransitioningDelegate

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SemiModalPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            tint: .dark,
            usePreferredContentSize: usePreferredContentSize
        )
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SemiModalDismissalAnimator()
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        (presentationController as? SemiModalPresentationController)?.interactionController
    }
}

class SemiModalDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let fromView = transitionContext.view(forKey: .from) else {
            return UIViewPropertyAnimator()
        }

        let containerView = transitionContext.containerView

        guard let visualEffectView = containerView.subviews.first?.subviews.first as? UIVisualEffectView else {
            return UIViewPropertyAnimator()
        }

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                              curve: transitionContext.isInteractive ? .linear : .easeInOut) {
            fromView.frame.origin.y = containerView.frame.height
            visualEffectView.effect = nil
        }

        animator.addCompletion { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        return animator
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let anim = self.interruptibleAnimator(using: transitionContext)
        anim.startAnimation()
    }
}

