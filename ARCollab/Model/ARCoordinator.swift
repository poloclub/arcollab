//
//  ARCoordinator.swift
//  CollabTest
//
//  Created by Rahul on 3/13/24.
//

import SwiftUI
import MultipeerConnectivity
import ARKit

class ARCoordinator: ObservableObject {
    private static let appDataKey = "arcollab-app_data"
    enum SessionMode: String, CaseIterable, Codable {
        case slice = "Slice"
        case object = "View"
    }

    struct ControlState: Codable {
        let name: String
    }

    struct SavedState: Codable {
        let appData: AppData
    }

    var multipeerSession: MultipeerSession?

    @Published private var availablePeers = Set<MCPeerID>()
    @Published private var connectedPeers = Set<MCPeerID>()
    @Published private(set) var appData = AppData()
    @Published var sessionMode: SessionMode = .object {
        didSet {
            sendUpdatedSessionMode()
            if sessionMode == .slice, isSliceHidden {
                toggleHideSlice()
            }
        }
    }
    @Published private(set) var isSliceHidden = true
    @Published private(set) var previouslySavedAppData: AppData?
    @Published private(set) var didPlaceModel = false
    @Published private(set) var currentControlState: ControlState? {
        didSet {
            print("control state: \(currentControlState)")
        }
    }
    @Published private(set) var showScanMessage = false

    private var shouldSendUpdatedSessionMode = true // workaround to avoid network cycle

    var localModelPath: URL?
    var didReceiveDataHandler: ((Data, MCPeerID) -> Void)?
    var toggleHideSliceHandler: (() -> (Bool))?
    var resetSliceHandler: (() -> ())?
    var resetModelHandler: (() -> ())?
    var toggleSliceOrientationHandler: (() -> ())?
    var loadPreviousStateHandler: ((AppData) -> ())?

    var availableDevices: [MCPeerID] {
        Array(availablePeers)
    }

    var connectedDevices: [MCPeerID] {
        Array(connectedPeers)
    }

    var controlStateColor: Color {
        if currentControlState?.name == multipeerSession?.session.myPeerID.displayName {
            return .green
        } else {
            return .red
        }
    }

    init() {
        getPreviouslySavedData()
    }

    func reset() {
        isSliceHidden = true
        didPlaceModel = false
        localModelPath = nil
        
    }

    // MARK: - User Intents
    func setNameAndLookForDevices(name: String) {
        multipeerSession = MultipeerSession(name: name)
        multipeerSession?.arMultipeerSessionDelegate = self
    }

    func requestConnection(with peer: MCPeerID) {
        multipeerSession?.invitePeer(peer)
    }

    func updateLocalModelPath(newValue: URL?) {
        self.localModelPath = newValue
    }

    func beginARSession() {
        appData.currentState = .arSession
        sendAppDataToPeers()
    }

    func endARSession() {
        appData.currentState = .connectingToDevices
        sendAppDataToPeers()
    }

    func updateMaterialSlice(newValue: SIMD4<Float>) {
        appData.modelData.planeInfo.materialSlice = newValue
    }

    func updatePlanePosition(newValue: SIMD3<Float>) {
        appData.modelData.planeInfo.planePosition = newValue
    }

    func updatePlaneRotation(newValue: simd_quatf) {
        appData.modelData.planeInfo.planeRotation = .init(matrix: newValue)
    }

    func updateRotationMatrix(newValue: simd_quatf) {
        appData.modelData.rotationInfo = .init(matrix: newValue)
    }
    
    func updateScale(newValue: Float) {
        appData.modelData.scaleInfo = .init(scale: newValue)
    }

    func updateAppData(using appData: AppData) {
        self.appData = appData
    }

    func updateControlState(isControlling: Bool) {
        guard let multipeerSession else { return }

        currentControlState = ControlState(name: isControlling ? multipeerSession.session.myPeerID.displayName : "")

        sendControlStateToPeers()
    }

    func toggleHideSlice() {
        if let hidden = toggleHideSliceHandler?() {
            isSliceHidden = hidden
        }
    }

    func resetSlice() {
        if sessionMode == .slice {
            resetSliceHandler?()
        } else if sessionMode == .object {
            resetModelHandler?()
        }
    }
    
    func toggleSliceOrientation() {
        toggleSliceOrientationHandler?()
    }

    func saveCurrentState(data: AppData? = nil, shouldSend: Bool = false) {
        let dataToSave = data == nil ? self.appData : data

        do {
            let encodedState = try JSONEncoder().encode(dataToSave)

            UserDefaults.standard.setValue(encodedState, forKey: Self.appDataKey)

            previouslySavedAppData = appData
        } catch {
            print("could not encode state: \(error)")
        }

        if shouldSend {
            sendPreviouslySavedStateToPeers()
        }
    }

    func loadPreviousState() {
        guard let previouslySavedAppData else { return }

        loadPreviousStateHandler?(previouslySavedAppData)
    }

    func didTapOnScreen(placedAnchor: Bool) {
        showScanMessage = !placedAnchor
        if showScanMessage {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self.showScanMessage = false
            }
        } else {
            didPlaceModel = true
        }
    }

    // MARK: - Multipeer Functions
    func connectedTo(_ peer: MCPeerID) -> Bool {
        connectedPeers.contains(peer)
    }

    func sendAppDataToPeers() {
        do {
            let data = try JSONEncoder().encode(appData)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode app data: \(error)")
        }
    }

    func sendRotationInfoToPeers() {
        do {
            let data = try JSONEncoder().encode(appData.modelData.rotationInfo)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode rotation data: \(error)")
        }
    }

    func sendModelDataToPeers() {
        do {
            let data = try JSONEncoder().encode(appData.modelData)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode model data: \(error)")
        }
    }

    func sendPlaneInfoToPeers() {
        do {
            let data = try JSONEncoder().encode(appData.modelData.planeInfo)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode plane data: \(error)")
        }
    }
    
    func sendPlaneRotationInfoToPeers() {
        do {
            let data = try JSONEncoder().encode(appData.modelData.planeInfo.planeRotation)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode plane data: \(error)")
        }
    }
    
    func sendScaleInfoToPeers() {
        do {
            let data = try JSONEncoder().encode(appData.modelData.scaleInfo)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode model scale data: \(error)")
        }
    }

    func sendUpdatedSessionMode() {
        if shouldSendUpdatedSessionMode {
            do {
                let data = try JSONEncoder().encode(sessionMode)

                multipeerSession?.sendToAllPeers(data, reliably: true)
            } catch {
                print("Could not encode model data: \(error)")
            }
        }
    }

    func sendControlStateToPeers() {
        do {
            let data = try JSONEncoder().encode(currentControlState)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode control state data: \(error)")
        }
    }

    func sendPreviouslySavedStateToPeers() {
        guard let previouslySavedAppData else { return }

        do {
            let savedData = SavedState(appData: previouslySavedAppData)

            let data = try JSONEncoder().encode(savedData)

            multipeerSession?.sendToAllPeers(data, reliably: true)
        } catch {
            print("Could not encode control state data: \(error)")
        }
    }

    // MARK: - Private
    private func getPreviouslySavedData() {
        if let savedData = UserDefaults.standard.data(
            forKey: Self.appDataKey
        ), let decodedData = try? JSONDecoder().decode(AppData.self, from: savedData) {
            self.previouslySavedAppData = decodedData
        }
    }
}

extension ARCoordinator: ARMultipeerSessionDelegate {
    func didReceiveData(_ data: Data, from id: MCPeerID) {
        print("received data: \(data)")
        if let newAppData = try? JSONDecoder().decode(AppData.self, from: data) {
            print("received new app data: \(newAppData)")
            appData.updateState(using: newAppData)
        } else if let newRotationInfo = try? JSONDecoder().decode(AppData.RotationInfo.self, from: data) {
            appData.modelData.rotationInfo = newRotationInfo
        } else if let newPlaneInfo = try? JSONDecoder().decode(AppData.PlaneInfo.self, from: data) {
            appData.modelData.planeInfo = newPlaneInfo
        } else if let newModelInfo = try? JSONDecoder().decode(AppData.ModelData.self, from: data) {
            appData.modelData = newModelInfo
        } else if let newSessionMode = try? JSONDecoder().decode(SessionMode.self, from: data) {
            shouldSendUpdatedSessionMode = false
            self.sessionMode = newSessionMode
            shouldSendUpdatedSessionMode = true
        } else if let newControlState = try? JSONDecoder().decode(ControlState.self, from: data) {
            self.currentControlState = newControlState
        } else if let savedData = try? JSONDecoder().decode(SavedState.self, from: data) {
            self.previouslySavedAppData = savedData.appData

            saveCurrentState(data: savedData.appData, shouldSend: false)
        }

        didReceiveDataHandler?(data, id)
    }
    
    func peerDidChangeState(_ peer: MCPeerID, to newState: MCSessionState) {
        if newState == .connected {
            connectedPeers.insert(peer)
        } else if newState == .notConnected {
            connectedPeers.remove(peer)
        }
    }
    
    func didFindPeer(_ peer: MCPeerID) {
        availablePeers.insert(peer)
    }
    
    func didLosePeer(_ peer: MCPeerID) {
        availablePeers.remove(peer)
    }
}
