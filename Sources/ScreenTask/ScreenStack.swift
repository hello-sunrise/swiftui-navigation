import SwiftUI
import AsyncQueue

internal class ScreenStack: NSObject {
    private let queue = FIFOQueue(priority: .userInitiated)
    
    let rootViewController: UIViewController
    
    var currentScreen: Screen {
        didSet {
            onScreenChanged?(currentScreen)
        }
    }
    
    var onScreenChanged: ((Screen) -> Void)?
    
    init(viewController: UIViewController, screen: Screen) {
        self.rootViewController = viewController
        self.currentScreen = screen
        super.init()
        Task(on: queue) {
            await self.rootViewController.setScreen(screen, animated: false)
        }
    }
    
    func push(
        screen: Screen,
        pushTransition: Transition,
        popTransition: Transition,
        animated: Bool
    ) {
        Task(on: queue) { @MainActor in
            screen.transition = pushTransition
            if (pushTransition == .sheet) {
                screen.presentationController?.delegate = self
            }
            await self.currentScreen.present(screen, animated: animated && pushTransition != .none)
            if popTransition != pushTransition {
                screen.transition = popTransition
            }
            self.currentScreen = screen
        }
    }
    
    func popUntil(screenName: String, arguments: [String: Any], inclusive: Bool, animated: Bool) {
        Task(on: queue) { @MainActor in
            var screen: Screen! = self.currentScreen
            
            while screen != nil && screen.name != screenName {
                screen = screen.presentingViewController?.screen
            }
            if screen == nil {
                print("🎱 ScreenStack/popUntil(screenName: \(screenName), arguments: \(arguments)) 🎱")
                print("🧐 Could not retrieve any screen named \"\(screenName)\" in this hierarchy. 🧐")
                print("🚧 It should never happen : please contact developers team. 🚧")
                return
            }
            
            self.currentScreen.transition = screen.transition
            if inclusive, let parent = screen.presentingViewController?.screen {
                screen = parent
            }
            
            await screen.dismiss(animated: animated)
            self.currentScreen = screen
            self.currentScreen.onNavigateTo(arguments)
        }
    }
    
    func pop(arguments: [String : Any], animated: Bool) {
        popUntil(screenName: currentScreen.name, arguments: arguments, inclusive: true, animated: animated)
    }
    
    func clear(asNewRoot screen: Screen? = nil, animated: Bool) {
        Task(on: queue) { @MainActor in
            if let screen = screen {
                await self.rootViewController.setScreen(screen, animated: animated)
                self.currentScreen = screen
            }
            if self.rootViewController.presentedViewController != nil {
                await self.rootViewController.dismiss(animated: false)
            }
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
    
    func setScreen(_ screen: Screen, animated: Bool) async {
        let oldScreen: Screen? = children.first as? Screen
        oldScreen?.view.alpha = 1.0
        
        addChild(screen)
        screen.view.frame = view.frame
        screen.view.alpha = 0.0
        view.addSubview(screen.view)

        if (animated) {
            await withUnsafeContinuation { continuation in
                UIView.animate(withDuration: 0.25, animations: {
                    screen.view.alpha = 1.0
                    oldScreen?.view.alpha = 0.0
                }) { finished in
                    continuation.resume()
                }
            }
        }
        screen.view.alpha = 1.0
        screen.didMove(toParent: self)
        if let oldScreen = oldScreen {
            oldScreen.willMove(toParent: nil)
            oldScreen.view.removeFromSuperview()
            oldScreen.removeFromParent()
        }
    }
    
    func present(_ viewController: UIViewController, animated: Bool) async {
        await withUnsafeContinuation { continuation in
            present(viewController, animated: animated) {
                continuation.resume()
            }
        }
    }
    
    func dismiss(animated: Bool) async {
        await withUnsafeContinuation { continuation in
            dismiss(animated: animated) {
                continuation.resume()
            }
        }
    }
}
