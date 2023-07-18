//
//  ScreenD.swift
//  Sample
//
//  Created by Vincent Lemonnier on 18/07/2023.
//

import SwiftUI
import SwiftNav

struct ScreenD: View {
    
    @EnvironmentObject
    var navController: NavController
    
    var body: some View {
        VStack {
            Button("< Back") {
                navController.pop()
            }
            Spacer()
            Text("Screen D")
                .font(.title)
            Spacer()
            Button("Pop to root") {
                navController.pop(to: "ScreenA")
            }
        }
    }
}

struct ScreenD_Previews: PreviewProvider {
    static var previews: some View {
        ScreenD()
    }
}
