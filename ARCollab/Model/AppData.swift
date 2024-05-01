//
//  AppData.swift
//  CollabTest
//
//  Created by Rahul on 3/13/24.
//

import Foundation
import ARKit

struct AppData: Codable {
    enum AppState: Int, CaseIterable, Codable {
        case connectingToDevices = 0
        case arSession
    }

    struct RotationInfo: Codable {
        var x: Float
        var y: Float
        var z: Float
        var w: Float

        init(matrix: simd_quatf) {
            x = matrix.imag.x
            y = matrix.imag.y
            z = matrix.imag.z
            w = matrix.real
        }

        var matrix: simd_quatf {
            simd_quatf(ix: x, iy: y, iz: z, r: w)
        }
    }
    
    struct PlaneRotationInfo: Codable {
        var rotationInfo: RotationInfo = RotationInfo(matrix: .init(ix: 0, iy: 1, iz: 0, r: 0))
        
        init(matrix: simd_quatf) {
            self.rotationInfo.x = matrix.imag.x
            self.rotationInfo.y = matrix.imag.y
            self.rotationInfo.z = matrix.imag.z
            self.rotationInfo.w = matrix.real
        }
    }
    
    struct ScaleInfo: Codable {
        var scale: Float
        
        init(scale: Float) {
            self.scale = scale
        }
    }

    struct PlaneInfo: Codable {
        var planePosition: SIMD3<Float> = SIMD3(repeating: 0.0)
        var planeRotation: PlaneRotationInfo = PlaneRotationInfo(matrix: .init(ix: 0, iy: 1, iz: 0, r: 0))
        var materialSlice: SIMD4<Float> = RealityView.defaultSlice
    }

    struct ModelData: Codable {
        var scaleInfo: ScaleInfo = ScaleInfo(scale: 0.008)
        var planeInfo = PlaneInfo()
        var rotationInfo: RotationInfo = RotationInfo(matrix: simd_quatf(vector: [0, 0, 0, 0]))
    }

    var currentState: AppState = .connectingToDevices
    var modelData = ModelData()

    mutating func updateState(using other: AppData) {
        self.currentState = other.currentState
        self.modelData = other.modelData
    }
}
