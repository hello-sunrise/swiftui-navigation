//
//  ScreenA.swift
//  Sample
//
//  Created by Vincent Lemonnier on 17/07/2023.
//

import SwiftUI
import SwiftNav

struct ScreenA: View {
    
    @EnvironmentObject
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

struct ScreenA_Previews: PreviewProvider {
    static var previews: some View {
        ScreenA()
    }
}
