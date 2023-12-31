import SwiftUI

/// A type that represents the entry point of your app navigation.
///```
///    var body: some Scene {
///        WindowGroup {
///            NavHost(controller: controller)
///        }
///    }
///```
///
/// Once ``NavHost`` is called, each screen declared into ``NavGraphBuilder``
/// can be navigated to using the ``NavController`` that holds the builder.
///
/// As ``NavHost`` extends the `View` protocol, a set of modifiers
/// are provided, as described in `Configuring-Views`.
/// For example, adding the ``View/background(_)`` modifier :
///
///     NavHost(controller: controller)
///                .background(.clear) // Display .clear background set.
///
/// The complete list of default modifiers provides a large set of controls
/// for managing this view.
public struct NavHost: View {
    private let windowBackgroundColor: Color?
    
    @ObservedObject
    private var controller: NavController
    
    /// - Parameters:
    ///     - controller: ``NavController`` instance that will control the screens.
    ///     - backgroundColor: Will be used as default background color for all the screens.
    ///     - windowBackgroundColor: Will set the window's background color. Default is nil
    public init(controller: NavController, backgroundColor: Color, windowBackgroundColor: Color? = nil) {
        self.windowBackgroundColor = windowBackgroundColor
        self.controller = controller
        self.controller.backgroundColor = backgroundColor
    }
        
    public var body: some View {
        EmptyView()
            .onAppear {
                if controller.viewController == nil {
                    window?.backgroundColor = windowBackgroundColor?.uiColor
                    controller.viewController = window?.rootViewController
                }
            }
    }
    
    private var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
}
