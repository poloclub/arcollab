//
//  ContentView.swift
//  CollabTest
//
//  Created by Rahul on 3/13/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var arCoordinator = ARCoordinator()
    @State private var showingARCollabView = false

    var body: some View {
        LaunchView()
            .environmentObject(arCoordinator)
            .onChange(of: arCoordinator.appData.currentState) { newState in
                showingARCollabView = (newState == .arSession)
            }
            .fullScreenCover(isPresented: $showingARCollabView) {
                ARCollabView()
                    .environmentObject(arCoordinator)
                    .onDisappear {
                        arCoordinator.reset()
                    }
            }
    }
}

#Preview {
    ContentView()
}
