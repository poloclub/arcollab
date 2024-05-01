//
//  LaunchView.swift
//  CollabTest
//
//  Created by Rahul on 4/12/24.
//

import SwiftUI

struct LaunchView: View {
    @EnvironmentObject private var arCoordinator: ARCoordinator
    @State private var showingDevices = false
    @State private var name = ""

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                Image("LaunchImage")
                    .resizable()
                    .frame(width: 230, height: 230)

                if !showingDevices {
                    Spacer()
                        .frame(height: 100)

                    TextField("Enter a name...", text: $name)
                        .padding()
                        .textFieldStyle(.roundedBorder)

                    Button("Start") {
                        showingDevices = true
                        arCoordinator.setNameAndLookForDevices(name: name)
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title3)
                    .bold()
                    .disabled(name.isEmpty)

                } else {
                    DevicesList()
                    
                    Button("Begin Session") {
                        arCoordinator.beginARSession()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title3)
                    .bold()
                }
            }
            .overlay(alignment: .topLeading) {
                if showingDevices {
                    HStack {
                        Button { showingDevices.toggle() } label: {
                            Image(systemName: "chevron.backward.circle.fill")
                        }
                        .font(.largeTitle)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .animation(.default, value: showingDevices)
            .environment(\.colorScheme, .light)
        }
    }
}

#Preview {
    LaunchView()
        .environmentObject(ARCoordinator())
}
