//
//  ScreenC.swift
//  Sample
//
//  Created by Vincent Lemonnier on 17/07/2023.
//

import SwiftUI
import SwiftNav

struct ScreenC: View {
    
    @EnvironmentObject
    var navController: NavController
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack {
                Button("< Back") {
                    navController.pop()
                }
                Spacer()
                Text("Screen C")
                    .font(.title)
                Spacer()
                Button("Open Sheet") {
                    navController.push(screenName: "ScreenD", transition: .sheet)
                }
            }.foregroundColor(.white)
        }
    }
}

struct ScreenC_Previews: PreviewProvider {
    static var previews: some View {
        ScreenC()
    }
}
