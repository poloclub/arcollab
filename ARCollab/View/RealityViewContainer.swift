//
//  RealityViewContainer.swift
//  CollabTest
//
//  Created by Rahul on 3/14/24.
//

import SwiftUI

struct RealityViewContainer: UIViewRepresentable {
    @EnvironmentObject var arCoordinator: ARCoordinator

    public init() { }

    func makeUIView(context: Context) -> RealityView {
        let arView = RealityView(frame: .zero)
        
        arView.arCoordinator = arCoordinator
        arView.setup()
        return arView
    }

    func updateUIView(_ view: RealityView, context: Context) { }
    
}
