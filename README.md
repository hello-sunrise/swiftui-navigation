# SwiftNav

![Swift](https://img.shields.io/badge/Swift-5.x-orange)

 - [Introduction](#introduction) 
 - [Installation](#installation)
 - [Usage](#usage)
 - [Sample](#sample)
 - [Licence](#license)


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

## Usage

First of all, you have to set up a `NavController` that takes the following parameters :
1) root: The name of the first screen that you want to be displayed.
2) builder: That will help you establish your graph of screens

Then, build the `NavHost` by passing the instance of `NavController` and place it as the unique view of the window

> **Warning**
> Don't forget to declare `NavController` as `@ObservedObject`.

```swift
@main
struct YourApp: App {

    @ObservedObject
    var navController = NavController(root: "ScreenA") { graph in
        graph.screen("ScreenA") { SplashA() }
        graph.screen("ScreenB") { ScreenB() }
        graph.screen("ScreenC") { params in
            let title = params["title"] as! String
            ScreenC(title: title)
        }
    }

    var body: some Scene {
        WindowGroup {
            NavHost(controller: navController)
        }
    }
}
```

Furthermore inside your screens, the instance of `NavController` can be accessible by using `@EnvironmentObject`.
```swift
struct ScreenA: View {
    @EnvironmentOject
    var navController: NavController

    var body: some View {
        VStack {
            Spacer()
            Text("Screen A")
                .font(.title)
            Spacer()
            Button("Next >") {
                navController.push(screenName: "ScreenB", transition: .coverFullscreen)
            }
        }
    }
}
```

## Sample
You can find a sample [here](https://github.com/hello-sunrise/swiftui-navigation/tree/main/Sample/).

## License

**SwiftNav** is under MIT license. See the [LICENSE](LICENSE) file for more info.
