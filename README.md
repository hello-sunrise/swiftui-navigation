# SwiftNav

![Swift](https://img.shields.io/badge/Swift-5.x-orange)

🎱 Developer friendly library designed to easily setup navigation through your SwiftUI app.

# Contents
 - [Introduction](#introduction) 
 - [Installation](#installation)
 - [Public architecture](#public-architecture) 
    - [NavController](#navController) 
    - [NavGraphBuilder](#navGraphBuilder) 
    - [NavHost](#navHost) 
 - [Initialization](#initialization) 
 - [NavController methods summary](#navController-methods-summary) 
    - [push](#push) 
    - [pop](#pop) 
    - [setOnNavigateBack](#setOnNavigateBack) 
    - [setNewRoot](#setNewRoot) 
 - [Sample](#sample)  


## Introduction
`SwiftNav` is a pure swift library designed for the development of SwiftUI interface.

As the native navigation framework provided by Apple has serious limitations or even missing features, this library
gives a proper way to handle navigation in your application. It relies on the legacy UIKit framework which offers a great stability, well known screen transition/animations and so confidence as UIKit has been used for many years.
On top of that, the library has introduced notions of stacking and routing screen which allows to build a complex navigation for your application.

## Installation

You can add SwiftUI Navigation to an Xcode project by adding it as a package dependency.

> https://github.com/hello-sunrise/swiftui-navigation

If you want to use SwiftUI Navigation in a [SwiftPM](https://swift.org/package-manager/) project, it's as simple as adding it to a `dependencies` clause in your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/hello-sunrise/swiftui-navigation", from: "1.x.x")
]
```
    
## Public architecture
### NavController
Which is the part of the Navigation that orchestrates how screens are displayed.
It holds public methods that will be useful to perform navigation through the app.

### NavGraphBuilder
Which defines how to build screens of the app.
It is declared once into the NavController parameters.

### NavHost 
This is the View holder where each screen declared into the NavGraphBuilder will be displayed. 


## Initialization
Let admit that you have four different screens :
- Splash
- Home
- FirstName
- LastName

First of all you have to set up a `NavController` that takes as parameters :
1) root: The name of the first screen that you want to be displayed.
2) builder: The way above screens will be built

```swift
@main
struct SampleApp: App {
    @ObservedObject var controller =
        NavController(
            root: "Splash"
        ) { graph in
            graph.screen("Splash") { SplashScreen() }
            graph.screen("Home") { HomeScreen() }
            graph.screen("FirstName") { FirstNameScreen() }
            graph.screen("LastName") { navParams in
                let firstName = navParams["first_name"] as! String
                LastNameScreen(firstName: firstName)
            }
        }
    ...
}
```
As you can see in the above example, we have told to the `NavController` how to initialize **Four named screens**.
"LastName" builder is particular as it takes a **navParam** as entry parameter,
which is a `[String: Any]` that holds data passed through a push method call - see [push](#push) section.     

Now that we have defined how our screens will be built, we must pass the `NavController` to the `NavHost`
in order to display those screens.
```swift
@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavHost(controller: controller)
        }
    }
}
```

And ... Thats it ! Everything is ready, you can now manage the navigation using 
your newly set navControllers public methods from anywhere in your app !

> **Warning**
> In order to manipulate the navigation properly, you have to use the same instance 
> of the `NavController` that you have passed to `NavHost` as parameter.
>
> Consider using `@EnvironmentObject` or a singleton design pattern.


## NavController methods summary
### push
Use this method display a new screen.
You can pass **arguments** through the screen pushed :
```swift
private class FirstNameViewModel: ObservableObject {
    private var controller: NavController = resolve()
    @Published private(set) var firstName: String = ""

    func setFirstName(value: String) { self.firstName = value }
    
    func goToLastName() {
        controller.push(
            screenName: "LastName",
            arguments: ["first_name": firstName]
        )
    }
}
```

Those arguments are handled into the `NavGraphBuilder` :
```swift
@main
struct SampleApp: App {
    @ObservedObject var controller =
        NavController(
            root: ...
        ) { graph in
            ...
            graph.screen("LastName") { navParams in
            //HERE
                let firstName = navParams["first_name"] as! String
                LastNameScreen(firstName: firstName)
            }
        }
    ...
}
```

### pop
Use this method to remove screens from the stack.
You can pass **arguments** to the screen that will be displayed back
and chose a **specific screen** that you want to be at the top of the stack :
```swift
private class LastNameViewModel: ObservableObject {
    private var controller: NavController = resolve()
    @Published private(set) var lastName: String = ""
    private(set) var firstName: String = ""
    
    func backToFirstName() { controller.pop() } //Simple pop.
    
    func backToHome() {
        controller.pop( //Pop with arguments and specific destination.
            to: "Home",
            arguments: [
                "first_name": firstName,
                "last_name": lastName,
            ]
        )
    }
}
```
Those arguments are handled into the place where you are navigating back (see [setOnNavigateBack](#setOnNavigateBack))

### setOnNavigateBack
Allows you to define how the app should handle arguments on a **pop** navigation :
```swift
private class HomeViewModel: ObservableObject 
    private var controller: NavController = resolve()
    @Published private(set) var firstName: String = ""
    @Published private(set) var lastName: String = ""
    
    private init() {
        controller.setOnNavigateBack { args in
            if let firstName = args["first_name"] as? String, !firstName.isEmpty { //HERE
                self.firstName = firstName
            }
            
            if let lastName = args["last_name"] as? String, !lastName.isEmpty { //AND HERE
                self.lastName = lastName
            }
        }
    }
...
}
```

### setNewRoot
Clear the entire screen's stack and set a new screen as root.
```swift
private class HomeViewModel: ObservableObject {
    private var controller: NavController = resolve()
    
    func goToAuth() {
        controller.setNewRoot(screenName: "Login")
    }
}
```

## Sample
You can find a sample <a href="https://github.com/hello-sunrise/swiftui-navigation/tree/main/Sample/" target="_blank">HERE</a>


## License

**SwiftNav** is under MIT license. See the [LICENSE](LICENSE) file for more info.
