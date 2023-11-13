import SwiftUI

internal class Screen: UIHostingController<ScreenView>, Identifiable {
    let id: UUID = UUID()
    let name: String
    let backgroundColor: Color
    var onNavigateTo: ([String : Any]) -> Void = { _ in }

    @ObservedObject
    private var lifecycle: LifecycleObservable
    
    init(
        name: String,
        backgroundColor: Color,
        view: some View
    ) {
        self.name = name
        self.backgroundColor = backgroundColor
        let lifecycle = LifecycleObservable()
        self.lifecycle = lifecycle
        super.init(rootView: ScreenView(anyView: (view as? AnyView) ?? AnyView(view), lifecycle: lifecycle))
        self.view.backgroundColor = backgroundColor.uiColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.view.backgroundColor = self.backgroundColor.uiColor
    }
    
    var transition: Transition = .none {
        willSet {
            self.view.backgroundColor = self.backgroundColor.uiColor
            self.modalTransitionStyle = .coverVertical
            self.transitioningDelegate = nil
            let presentationStyle: UIModalPresentationStyle
            switch newValue {
            case .none:
                presentationStyle = .fullScreen
            case .coverFullscreen:
                modalTransitionStyle = .crossDissolve
                presentationStyle = .fullScreen
            case .coverOverFullscreen:
                view.backgroundColor = .clear
                modalTransitionStyle = .crossDissolve
                presentationStyle = .overFullScreen
            case .coverVertical:
                modalTransitionStyle = .coverVertical
                presentationStyle = .fullScreen
            case .coverHorizontal:
                presentationStyle = .custom
                transitioningDelegate = TransitionDelegate.coverHorizontal
            case .sheet:
                modalTransitionStyle = .coverVertical
                presentationStyle = .pageSheet
            }
            if presentingViewController == nil {
                modalPresentationStyle = presentationStyle
            }
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed || isMovingFromParent {
            lifecycle.isRemovedFromStack = true
        }
    }
}

internal class LifecycleObservable: ObservableObject {
    @Published
    var isRemovedFromStack: Bool = false
}

internal struct ScreenView: View {
    let anyView: AnyView
    @ObservedObject
    var lifecycle: LifecycleObservable
    
    var body: some View {
        anyView.environment(\.isRemovedFromStack, self.lifecycle.isRemovedFromStack)
    }
    
}
