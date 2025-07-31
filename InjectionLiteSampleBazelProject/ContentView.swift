//
//  ContentView.swift
//  InjectionLiteSampleBazelProject
//
//  Created by Karim Alweheshy on 30.07.25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    var body: AnyView {
        AnyView(
            NavigationView {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                    Text("Hello, world!")
                    NavigationLink(destination: ContentView2()) {
                        Text("Hello, world!")
                    }
                }
                .padding()
            }
        )
    }
}
