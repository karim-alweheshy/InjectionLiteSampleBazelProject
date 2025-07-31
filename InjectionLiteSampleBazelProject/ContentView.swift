//
//  ContentView.swift
//  InjectionLiteSampleBazelProject
//
//  Created by Karim Alweheshy on 30.07.25.
//

import SwiftUI
import Foundation
import HotSwiftUI

struct ContentView: View {
    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Text("Hello, world!")
                Text("Hello, world!")
                Text("Hello, world!")
                NavigationLink(destination: ContentView2()) {
                    Text("Hello, world!")
                }
                ContentView2()
            }
            .padding()
        }.eraseToAnyView()
    }
}
