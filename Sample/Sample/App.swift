//
//  SampleApp.swift
//  Sample
//
//  Created by Vincent Lemonnier on 17/07/2023.
//

import SwiftUI
import SwiftNav

@main
struct App: SwiftUI.App {
    
    @ObservedObject
    var navController: NavController = NavController(root: "ScreenA") { graph in
        graph.screen("ScreenA") { ScreenA() }
        graph.screen("ScreenB") { ScreenB() }
        graph.screen("ScreenC") { ScreenC() }
        graph.screen("ScreenD") { ScreenD() }
    }
    
    var body: some Scene {
        WindowGroup {
            NavHost(controller: navController, backgroundColor: .white)
        }
    }
}
