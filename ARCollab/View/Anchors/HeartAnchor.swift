//
//  HeartAnchor.swift
//  CollabTest
//
//  Created by Rahul on 3/14/24.
//

import ARKit

class HeartAnchor: ARAnchor {
    let modelData: Data?

    init(transform: simd_float4x4, data: Data) {
        self.modelData = data

        super.init(transform: transform)
    }

    required init?(coder aDecoder: NSCoder) {
        guard let modelData = aDecoder.decodeObject(forKey: "modelData") as? Data else {
            return nil
        }

        self.modelData = modelData
        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        aCoder.encode(modelData, forKey: "modelData")
        super.encode(with: aCoder)
    }

    override class var supportsSecureCoding: Bool {
        true
    }

    required init(anchor: ARAnchor) {
        self.modelData = nil
        super.init(anchor: anchor)
    }
}

