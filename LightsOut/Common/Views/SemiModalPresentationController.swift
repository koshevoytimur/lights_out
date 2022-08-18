//
//  SemiModalPresentationController.swift
//  LightsOut
//
//  Created by Essence K on 21.12.2021.
//

import UIKit

class SemiModalPresentationController: UIPresentationController {
  enum Tint {
    case light
    case dark

    var color: UIColor {
      switch self {
      case .dark:
        return Theme.dark.primaryColor.withAlphaComponent(0.5)
      case .light:
        return UIColor.lightGray.withAlphaComponent(0.5)
      }
    }
  }

  private lazy var visualEffectView: UIVisualEffectView = {
    let view = UIVisualEffectView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.clear
    return view
  }()

  private lazy var blurEffect = {
    UIBlurEffect(style: .dark)
  }()

  private lazy var dismissGestureRecognizer: UIPanGestureRecognizer = {
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(_:)))
    gestureRecognizer.delegate = self
    return gestureRecognizer
  }()

  var interactionController: UIPercentDrivenInteractiveTransition?

  override var shouldPresentInFullscreen: Bool {
    false
  }

  private lazy var dimmingView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(visualEffectView)
    view.addConstraints([
      visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
      visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDimmedArea(_:))))
    return view
  }()

  let usePreferredContentSize: Bool
  let tint: Tint

  init(
    presentedViewController: UIViewController,
    presenting presentingViewController: UIViewController?,
    tint: Tint = .light,
    usePreferredContentSize: Bool = true
  ) {
    self.usePreferredContentSize = usePreferredContentSize
    self.tint = tint
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView = containerView else {
      return super.frameOfPresentedViewInContainerView
    }

    let safeAreaFrame = containerView.safeAreaLayoutGuide.layoutFrame
    let bottomUnsafeArea = containerView.frame.maxY - safeAreaFrame.maxY
    let maxHeight = containerView.safeAreaLayoutGuide.layoutFrame.height + bottomUnsafeArea - 16

    guard usePreferredContentSize else {
      return CGRect(origin: CGPoint(x: 0, y: containerView.bounds.height - maxHeight),
                    size: CGSize(width: containerView.bounds.width, height: maxHeight))
    }

    let size = presentedViewController.preferredContentSize
    let preferredHeight = size.height // + bottomUnsafeArea
    let height = min(preferredHeight, maxHeight)

    return CGRect(origin: CGPoint(x: 0,
                                  y: containerView.frame.maxY - height),
                  size: CGSize(width: containerView.frame.width,
                               height: height))
  }

  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else {
      super.presentationTransitionWillBegin()
      return
    }

    containerView.insertSubview(dimmingView, at: 0)
    containerView.addConstraints([
      dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      dimmingView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
      dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      dimmingView.leftAnchor.constraint(equalTo: containerView.leftAnchor)
    ])

    if let coordinator = presentedViewController.transitionCoordinator {
      coordinator.animate(alongsideTransition: { _ in
//        self.visualEffectView.effect = self.blurEffect
        self.visualEffectView.backgroundColor = self.tint.color
      }, completion: nil)
    } else {
//      self.visualEffectView.effect = self.blurEffect
      self.dimmingView.backgroundColor = self.tint.color
    }
  }

  private var visibleOriginY: CGFloat?
  private var visibleHeight: CGFloat?

  override func dismissalTransitionWillBegin() {
    if let coordinator = presentedViewController.transitionCoordinator {
      coordinator.animate(alongsideTransition: { _ in
        self.visualEffectView.backgroundColor = UIColor.clear
      }, completion: nil)
    } else {
      self.dimmingView.backgroundColor = UIColor.clear
    }
  }

  override func dismissalTransitionDidEnd(_ completed: Bool) {
    presentingViewController.setNeedsStatusBarAppearanceUpdate()
  }

  override func presentationTransitionDidEnd(_ completed: Bool) {
    guard let containerView = containerView, let presentedView = presentedView else {
      return
    }

    self.visibleOriginY = containerView.frame.maxY - presentedView.frame.height
    self.visibleHeight = presentedView.frame.height

    presentedView.addGestureRecognizer(dismissGestureRecognizer)
  }

  override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
    super.preferredContentSizeDidChange(forChildContentContainer: container)

    guard let containerView = containerView, let presentedView = presentedView else {
      return
    }

    guard interactionController == nil else {
      interactionController?.cancel()
      return
    }

    containerView.layoutIfNeeded()

    UIView.animate(withDuration: 0.3) {
      presentedView.frame = self.frameOfPresentedViewInContainerView
      containerView.layoutIfNeeded()
    } completion: { _ in
      self.visibleOriginY = containerView.frame.maxY - presentedView.frame.height
      self.visibleHeight = presentedView.frame.height
    }
  }
}

@objc
extension SemiModalPresentationController {
  func didTapDimmedArea(_ sender: Any) {
    presentingViewController.dismiss(animated: true, completion: nil)
  }

  func panView(_ recognizer: UIPanGestureRecognizer) {
    guard let presentedView = presentedView, let visibleHeight = visibleHeight, let visibleOriginY = visibleOriginY else {
      return
    }

    let translation = recognizer.translation(in: presentedView)

    switch recognizer.state {
    case .began:
      break
    case .changed where interactionController == nil && translation.y < 0 && translation.y > -20:
      presentedView.frame.size.height = visibleHeight + abs(translation.y)
      presentedView.frame.origin.y = visibleOriginY + translation.y
    case .changed where interactionController == nil && translation.y > 0:
      presentedView.frame.size.height = visibleHeight
      presentedView.frame.origin.y = visibleOriginY
      interactionController = UIPercentDrivenInteractiveTransition()
      presentingViewController.dismiss(animated: true, completion: nil)
    case .changed where interactionController != nil:
      let verticalMovement = translation.y / presentedView.bounds.height
      let progress = verticalMovement
      interactionController?.update(progress)
    case .ended where interactionController == nil:
      presentedView.frame.size.height = visibleHeight
      presentedView.frame.origin.y = visibleOriginY
    case .ended where interactionController != nil && interactionController!.percentComplete < 0.3:
      interactionController?.cancel()
      interactionController = nil
    case .ended where interactionController != nil && interactionController!.percentComplete > 0.3:
      interactionController?.finish()
      interactionController = nil
    case .cancelled:
      interactionController?.cancel()
      interactionController = nil
    case .failed:
      interactionController?.cancel()
      interactionController = nil
    default:
      break
    }
  }
}

extension SemiModalPresentationController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    guard let scrollView = otherGestureRecognizer.view as? UIScrollView,
          scrollView.contentOffset.y == 0,
          let presentedView = presentedView,
          let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
          panGestureRecognizer.translation(in: presentedView).y > 0 else {
      return false
    }

    otherGestureRecognizer.isEnabled = false
    otherGestureRecognizer.isEnabled = true
    return true
  }
}
