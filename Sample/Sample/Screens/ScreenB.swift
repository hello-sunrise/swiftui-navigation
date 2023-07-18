//
//  ScreenB.swift
//  Sample
//
//  Created by Vincent Lemonnier on 17/07/2023.
//

import SwiftUI
import SwiftNav

struct ScreenB: View {
    
    @EnvironmentObject
    var navController: NavController
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            VStack {
                Button("< Back") {
                    navController.pop()
                }
                Spacer()
                Text("Screen B")
                    .font(.title)
                Spacer()
                Button("Next >") {
                    navController.push(screenName: "ScreenC", transition: .coverHorizontal)
                }
            }
            .foregroundColor(.white)
        }
    }
}

struct ScreenB_Previews: PreviewProvider {
    static var previews: some View {
        ScreenB()
    }
}
