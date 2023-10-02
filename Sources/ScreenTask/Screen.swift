import SwiftUI

internal class Screen: UIHostingController<AnyView>, Identifiable {
    let id: UUID = UUID()
    let name: String
    let backgroundColor: Color
    var onNavigateTo: ([String : Any]) -> Void = { _ in }

    init(
        name: String,
        backgroundColor: Color,
        view: some View
    ) {
        self.name = name
        self.backgroundColor = backgroundColor
        super.init(rootView: (view as? AnyView) ?? AnyView(view))
        self.view.backgroundColor = backgroundColor.uiColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.view.backgroundColor = self.backgroundColor.uiColor
    }
}
