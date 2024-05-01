//
//  DevicesList.swift
//  CollabTest
//
//  Created by Rahul on 3/13/24.
//

import SwiftUI
import MultipeerConnectivity

struct DevicesList: View {
    @EnvironmentObject private var arCoordinator: ARCoordinator

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Available Devices")
                    .foregroundStyle(.black)
                    .font(.title)
                    .bold()

                Spacer()
            }

            ScrollView {
                ForEach(arCoordinator.availableDevices, id: \.self) { peer in
                    rowCell(for: peer)
                }
            }
        }
        .frame(maxHeight: 400)
        .padding()
        .background(.secondary.opacity(0.1), in: .rect(cornerRadius: 8))
        .padding()
    }

    private func rowCell(for peer: MCPeerID) -> some View {
        Button {
            arCoordinator.requestConnection(with: peer)
        } label: {
            HStack {
                Text(peer.displayName)
                    .font(.headline)
                Spacer()
                if arCoordinator.connectedTo(peer) {
                    Text("Connected")
                        .foregroundStyle(.secondary)
                        .bold()
                }
            }
            .padding()
            .background(.tertiary, in: .rect(cornerRadius: 6))
            .tint(arCoordinator.connectedTo(peer) ? .green : .accentColor)
        }
    }
}

#Preview {
    DevicesList()
        .environmentObject(ARCoordinator())
}
