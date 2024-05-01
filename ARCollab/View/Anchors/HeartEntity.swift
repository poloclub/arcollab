//
//  HeartEntity.swift
//  AnnotationTest
//
//  Created by Rahul on 2/23/24.
//

import ARKit
import RealityKit
import UIKit

class HeartEntity: Entity, HasModel, HasAnchoring, HasCollision {
    var modelPath: URL?

    required init?(heartAnchor: HeartAnchor) {
        super.init()

        self.transform.matrix = heartAnchor.transform

        if let modelData = heartAnchor.modelData {
            modelPath = Self.writeModelDataToURL(modelData)
            // print("modelPath: \(modelPath)")
            if let modelPath {
                guard let modelEntity = try? ModelEntity.loadModel(contentsOf: modelPath) else { return nil }
                self.components[ModelComponent.self] = modelEntity.model
            }
        }
    }

    private static func writeModelDataToURL(_ data: Data) -> URL? {
        let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent("model.obj") // +"modelPath.obj"

        do {
            try data.write(to: destinationUrl, options: .atomic)
            return destinationUrl
        } catch {
            print("error: \(error)")
            return nil
        }


    }

    @MainActor required init() {
        super.init()
    }
}
