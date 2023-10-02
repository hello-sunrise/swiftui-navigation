//
//  Color+UIColor.swift
//  
//
//  Created by Vincent Lemonnier on 19/09/2023.
//

import SwiftUI

internal extension Color {
    var uiColor: UIColor {
        if self.description.contains("NamedColor") {
            let lowerBound = self.description.range(of: "name: \"")!.upperBound
            let upperBound = self.description.range(of: "\", bundle")!.lowerBound
            let name = String(self.description[lowerBound..<upperBound])
            
            return UIColor(named: name)!
        }
        return UIColor(self)
    }
}
