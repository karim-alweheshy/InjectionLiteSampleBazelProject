//
//  ContentView.swift
//  InjectionLiteSampleBazelProject
//
//  Created by Karim Alweheshy on 30.07.25.
//

import SwiftUI
@_exported import HotSwiftUI
import Foundation

struct ContentView2: View {
    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Hello, world!")
            Text("Hello, world!")
            Text("Hello, world!")
            Text("Hello, world!")
            Text("Hello, world!")
            Text("Hello, world!")
            Text("Hello, world!")
        }
        .padding()
        .eraseToAnyView()
    }
}
