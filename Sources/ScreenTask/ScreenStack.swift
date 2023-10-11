import SwiftUI

internal class ScreenStack: NSObject {
    let rootViewController: UIViewController
    
    var currentScreen: Screen
    
    init(viewController: UIViewController, screen: Screen) {
        self.rootViewController = viewController
        self.rootViewController.setScreen(screen, animated: false)
        self.currentScreen = screen
    }
    
    func push(
        screen: Screen,
        pushTransition: Transition,
        popTransition: Transition,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        screen.transition = pushTransition
        if (pushTransition == .sheet) {
            screen.presentationController?.delegate = self
        }
        currentScreen.present(screen, animated: animated && pushTransition != .none) {
            if popTransition != pushTransition {
                screen.transition = popTransition
            }
            completion()
        }
        currentScreen = screen
    }
    
    func popUntil(screenName: String, arguments: [String: Any], inclusive: Bool, animated: Bool) {
        var screen: Screen! = currentScreen
        
        while screen != nil && screen.name != screenName {
            screen = screen.presentingViewController?.screen
        }
        if screen == nil {
            print("🎱 ScreenStack/popUntil(screenName: \(screenName), arguments: \(arguments)) 🎱")
            print("🧐 Could not retrieve any screen named \"\(screenName)\" in this hierarchy. 🧐")
            print("🚧 It should never happen : please contact developers team. 🚧")
            return
        }
        
        currentScreen.transition = screen.transition
        if inclusive, let parent = screen.presentingViewController?.screen {
            screen = parent
        }
        
        screen.dismiss(animated: animated)
        currentScreen = screen
        currentScreen.onNavigateTo(arguments)
    }
    
    func pop(arguments: [String : Any], animated: Bool) {
        popUntil(screenName: currentScreen.name, arguments: arguments, inclusive: true, animated: animated)
    }
    
    func clear(asNewRoot screen: Screen? = nil, animated: Bool) {
        if let screen = screen {
            rootViewController.setScreen(screen, animated: animated)
            currentScreen = screen
        }
        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: false)
        }
    }
}

extension ScreenStack: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        currentScreen = presentationController.presentingViewController.screen
        currentScreen.onNavigateTo([:])
    }
}

private extension UIViewController {
    var screen: Screen {
        self as? Screen ?? (children.first as! Screen)
    }
    
    func setScreen(_ screen: Screen, animated: Bool) {
        let oldScreen: Screen? = children.first as? Screen
        oldScreen?.view.alpha = 1.0
        
        addChild(screen)
        screen.view.frame = view.frame
        screen.view.alpha = 0.0
        view.addSubview(screen.view)
        let completion = { (finished: Bool) -> Void in
            screen.view.alpha = 1.0
            screen.didMove(toParent: self)
            if let oldScreen = oldScreen {
                oldScreen.willMove(toParent: nil)
                oldScreen.view.removeFromSuperview()
                oldScreen.removeFromParent()
            }
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.25, animations: {
                screen.view.alpha = 1.0
                oldScreen?.view.alpha = 0.0
            }, completion: completion)
        } else {
            completion(true)
        }
    }
}
