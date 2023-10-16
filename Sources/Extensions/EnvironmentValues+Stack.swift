//
//  EnvironmentValues+Stack.swift
//
//
//  Created by Vincent Lemonnier on 16/10/2023.
//

import SwiftUI

public extension EnvironmentValues {
    internal(set) var isRemovedFromStack: Bool {
        get { self[IsRemovedFromStackKey.self] }
        set { self[IsRemovedFromStackKey.self] = newValue }
    }
}

private struct IsRemovedFromStackKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
