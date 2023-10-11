import SwiftUI

/// NavController is the part of the Navigation that orchestrate how screens are displayed.
///
/// The ``NavController`` is declared once and passed through the ``NavHost``
/// ```
///@main
///struct SampleApp: App {
///    @ObservedObject var controller =
///        NavController(
///            root: Route.Splash.name
///        ) { graph in
///            graph.screen("Splash") { SplashScreen() }
///            graph.screen("Home") { HomeScreen() }
///            graph.screen("FirstName") { FirstNameScreen() }
///            graph.screen("LastName") { navParams in
///                let firstName = navParams["first_name"] as! String
///                LastNameScreen(firstName: firstName)
///            }
///        }
///
///    init() {
///        register(
///            assemblies: [ AppAssembly(navController: self.controller) ]
///        )
///    }
///
///    var body: some Scene {
///        WindowGroup {
///            NavHost(controller: controller)
///                .background(.clear)
///                .preferredColorScheme(.dark)
///                .clipped()
///        }
///    }
///}
/// ```
/// After having set a `root` screen name to define which screen will
/// be displayed first and the graph of the app navigation :
/// ```
///    @ObservedObject var controller =
///        NavController(
///            root: Route.Splash.name
///        ) { graph in
///            graph.screen("Splash") { SplashScreen() }
///            graph.screen("Home") { HomeScreen() }
///            graph.screen("FirstName") { FirstNameScreen() }
///            graph.screen("LastName") { navParams in
///                let firstName = navParams["first_name"] as! String
///                LastNameScreen(firstName: firstName)
///            }
///        }
/// ```
/// The navController is ready to manage the screens once it is passed as
/// parameter through the ``NavHost`` :
///
/// ```
///        NavHost(controller: controller)
/// ```
///
/// Furthermore inside your screens, the instance of `NavController` can be accessible by using `@EnvironmentObject`.
/// ```
///private class HomeViewModel: ObservableObject {
///    @EnvironmentOject
///    var navController: NavController
///
///    var body: some View {
///        VStack {
///            Spacer()
///            Text("Screen A")
///                .font(.title)
///            Spacer()
///            Button("Next >") {
///                navController.push(screenName: "ScreenB", transition: .coverFullscreen)
///            }
///        }
///    }
///}
/// ```
public class NavController: ObservableObject {
    private let navGraph = NavGraph()
    private let root: String
    private let defaultTransition: Transition
    private var screenStack: ScreenStack!
    
    internal var backgroundColor: Color!
    
    internal var viewController: UIViewController? {
        didSet {
            guard let viewController = viewController else { return }
            let rootScreen = navGraph.screenBuilder(of: root)!.screen(navController: self, arguments: [:])
            self.screenStack = ScreenStack(viewController: viewController, screen: rootScreen)
        }
    }
    
    /// - Parameters:
    ///     - root: The name of the first screen that will be displayed.
    ///     - defaultTransition: Default transition that will be used if not specified.
    ///     - builder: ``NavGraphBuilder`` that defines how the app screens will be built.
    public init(
        root: String,
        defaultTransition: Transition = .none,
        builder: NavGraphBuilder
    ) {
        self.root = root
        self.defaultTransition = defaultTransition
        builder(navGraph)
    }
    
    /// Clear the entire screen's stack and set `screenName` as new root.
    ///
    /// Use this method to keep only the last screen displayed into its stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB, ScreenC.
    ///
    /// controller.setNewRoot(screenName: "ScreenD")
    ///
    /// // screenStack : ScreenD
    /// ```
    /// This method uses the transition `TransitionStyle.coverFullscreen`.
    ///
    /// - Parameters:
    ///     - screenName: The screen name allows you to navigate back to a chosen screen by entering its name.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the popped screen.
    ///     - animated: Pass true to animate the transition; otherwise, pass false.
    public func setNewRoot(screenName: String, arguments: [String: Any] = [:], animated: Bool = true) {
        guard let newScreen = navGraph.screenBuilder(of: screenName)?.screen(navController: self, arguments: arguments) else { return }
        screenStack.clear(asNewRoot: newScreen, animated: animated)
    }
    
    /// Display a screen that was shown previously into the hierarchy.
    ///
    /// Use this method to remove one or many screens from the backstack.
    /// ```
    /// // screenStack : ScreenA, ScreenB, ScreenC and ScreenD.
    ///
    /// controller.pop()
    ///
    /// // screenStack : ScreenA, ScreenB and ScreenC
    ///
    /// controller.pop(to: "ScreenB", inclusive: true)
    ///
    /// // screenStack : ScreenA
    /// ```
    /// As you can see in the above example, as we are using `ScreenB` as target destination with `inclusive` parameter.
    /// Each screen shown after `ScreenB` included are erased from screenStack.
    ///
    /// - Parameters:
    ///     - screenName: The screen name allows you to navigate back to a chosen screen by entering its name.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the popped screen.
    ///     - inclusive: Pass true to popped out of the stack `screenName`, otherwise pass false.
    ///     - animated: Pass true to animate the transition; otherwise, pass false.
    public func pop(to screenName: String? = nil, arguments: [String : Any] = [:], inclusive: Bool = false, animated: Bool = true) {
        if let screenName = screenName {
            screenStack.popUntil(screenName: screenName, arguments: arguments, inclusive: inclusive, animated: animated)
        } else {
            screenStack.pop(arguments: arguments, animated: animated)
        }
    }
    
    /// Push a new screen to the backstack.
    ///
    /// Use this method to add a screen to the last navigation contexts stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "SheetA", transition: .sheet)
    ///
    /// // screenStack : ScreenA, ScreenB, ScreenC and SheetA.
    ///
    /// ```
    /// If the controller cannot find any related view from the graph, console will prompt logs.
    ///
    /// - Parameters:
    ///     - screenName: The screen name of the screen that will be used to retrieve a ViewBuilding from the `NavGraph`.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the newly pushed screen.
    ///     - pushTransition: Sets the animation that will be triggered when pushing this screen. Default is the value of `defaultTransition`.
    ///     - popTransition: Sets the animation that will be triggered when popping out this screen. Default is the value of `defaultTransition`.
    ///     - animated: Pass true to animate the transition; otherwise, pass false.
    ///     - completion: The block to execute after the push finishes. This block has no return value and takes no parameters.
    public func push(
        screenName: String,
        arguments: [String : Any] = [:],
        pushTransition: Transition? = nil,
        popTransition: Transition? = nil,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        guard let screenBuilder = navGraph.screenBuilder(of: screenName) else  { return }
        let screen = screenBuilder.screen(navController: self, arguments: arguments)
        let defaultTransition = screenBuilder.defaultTransition ?? defaultTransition
        
        screenStack.push(
            screen: screen,
            pushTransition: pushTransition ?? defaultTransition,
            popTransition: popTransition ?? defaultTransition,
            animated: animated,
            completion: completion
        )
    }
    
    /// Push a new screen to the backstack.
    ///
    /// Use this method to add a screen to the last navigation contexts stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "ScreenD") {
    ///     Text("I am ScreenD")
    /// }
    ///
    /// // screenStack : ScreenA, ScreenB, ScreenC and ScreenD.
    /// ```
    /// If the controller cannot find any related view from the graph, console will prompt logs.
    ///
    /// - Parameters:
    ///     - screenName: The name of the screen that will be used to retrieve a ViewBuilding from the `NavGraph`.
    ///     - pushTransition: Sets the animation that will be triggered when pushing this screen. Default is the value of `defaultTransition`.
    ///     - popTransition: Sets the animation that will be triggered when popping out this screen. Default is the value of `defaultTransition`.
    ///     - animated: Pass true to animate the transition; otherwise, pass false.
    ///     - completion: The block to execute after the push finishes. This block has no return value and takes no parameters.
    ///     - content: This `() -> some View` closure defines the screen that you want to see displayed.
    public func push(
        screenName: String,
        pushTransition: Transition? = nil,
        popTransition: Transition? = nil,
        animated: Bool = true,
        completion: @escaping () -> Void = {},
        @ViewBuilder content: () -> some View
    ) {
        screenStack.push(
            screen: Screen(name: screenName, backgroundColor: self.backgroundColor, view: content().environmentObject(self)),
            pushTransition: pushTransition ?? defaultTransition,
            popTransition: popTransition ?? defaultTransition,
            animated: animated,
            completion: completion
        )
    }
    
    /// Saves back navigation instructions
    ///
    /// When ``NavController/setOnNavigateBack(block:)`` is called, the instructions
    /// are linked to the calling screen, whenever we navigate back to it, the lambda contained into the closure is triggered.
    /// ```
    ///    private init() {
    ///        controller.setOnNavigateBack { args in
    ///            if let firstName = args["first_name"] as? String, !firstName.isEmpty {
    ///                self.firstName = firstName
    ///            }
    ///
    ///            if let lastName = args["last_name"] as? String, !lastName.isEmpty {
    ///                self.lastName = lastName
    ///            }
    ///        }
    ///    }
    /// ```
    ///
    /// - Parameters:
    ///     - block: This lambda defines the instructions to execute on a back navigation to the calling screen, the dictionary passed as entry parameter works as an arguments map.
    public func setOnNavigateBack(block: @escaping ([String : Any]) -> Void) {
        screenStack.currentScreen.onNavigateTo = block
    }
}

private extension ScreenBuilder {
    func screen(navController: NavController, arguments: [String: Any]) -> Screen {
        Screen(name: name, backgroundColor: navController.backgroundColor, view: builder(arguments).environmentObject(navController))
    }
}
