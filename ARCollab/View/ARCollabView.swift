//
//  ARCollabView.swift
//  CollabTest
//
//  Created by Rahul on 3/14/24.
//

import SwiftUI

struct ARCollabView: View {
    @EnvironmentObject private var arCoordinator: ARCoordinator
    @State private var showingFiles = false

    var body: some View {
        RealityViewContainer()
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                if arCoordinator.showScanMessage {
                    Text("Continue scanning to place object...")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.gray.opacity(0.7), in: RoundedRectangle(cornerRadius: 8.0))
                        .minimumScaleFactor(0.7)
                        .padding(.top)
                } else if let controlState = arCoordinator.currentControlState, !controlState.name.isEmpty {
                    Text("\(controlState.name) is controlling.")
                        .foregroundStyle(.white)
                        .padding()
                        .background(arCoordinator.controlStateColor.opacity(0.7), in: RoundedRectangle(cornerRadius: 8.0))
                        .minimumScaleFactor(0.7)
                        .padding(.top)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if !arCoordinator.didPlaceModel {
                    importButton
                        .padding(16)
                } else {
                    HStack(spacing: 16) {
                        if arCoordinator.sessionMode == .object {
                            hideSliceButton
                        } else {
                            toggleSliceOrientationButton
                        }
                        resetSliceButton
                    }
                    .padding(16)
                }
            }
            .overlay(alignment: .topLeading) {
                endSessionButton
                    .padding(16)
            }
            .overlay(alignment: .topTrailing) {
                if arCoordinator.didPlaceModel {
                    loadSavesButton
                        .padding(16)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                sessionModeControl
                    .frame(width: 150)
                    .padding(16)
            }
            .fileImporter(
                isPresented: $showingFiles,
                allowedContentTypes: [.threeDContent]
            ) { result in
                do {
                    let selectedFile: URL = try result.get()

                    // file importing code
                    guard selectedFile.startAccessingSecurityScopedResource() else {
                        // Handle the failure here.
                        return
                    }

                    let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                    let destinationUrl = documentsUrl.appendingPathComponent(selectedFile.lastPathComponent)
                    print("destinationURL: \(destinationUrl)")
                    // copies file to cache
                    if let dataFromURL = NSData(contentsOf: selectedFile) {
                        if dataFromURL.write(to: destinationUrl, atomically: true) {
                            arCoordinator.localModelPath = destinationUrl
                        } else {
                            fatalError("Error Saving and recording file")
                        }
                    }
                    // needed to avoid Apple security Failures
                    selectedFile.stopAccessingSecurityScopedResource()
                } catch {
                    print("error in file importer ", error)
                }
            }
            .environment(\.colorScheme, .light)
            .animation(.easeInOut, value: arCoordinator.showScanMessage)
    }

    private var importButton: some View {
        Button {
            showingFiles = true
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.thinMaterial)

                Image("custom.heart.fill.badge.plus")
                    .imageScale(.large)
                    .padding(8)
                    .foregroundStyle(.black)
                    .offset(y: 3)
            }
        }
        .frame(width: 30, height: 30)
    }

    private var loadSavesButton: some View {
        Menu {
            Button {
                arCoordinator.saveCurrentState(shouldSend: true)
            } label: {
                Label("Save State", systemImage: "square.and.arrow.down.fill")
            }

            Button {
                arCoordinator.loadPreviousState()
            } label: {
                Label("Load Previously Saved State", systemImage: "folder.fill")
            }
            .disabled(arCoordinator.previouslySavedAppData == nil)
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.thinMaterial)

                Image(systemName: "square.and.arrow.down.fill")
                    .imageScale(.large)
                    .padding(8)
                    .foregroundStyle(.black)
            }
        }
        .frame(width: 30, height: 30)
    }

    private var resetSliceButton: some View {
        ARCollabViewButton(systemImage: arCoordinator.sessionMode == .object ? "arrow.clockwise.heart" : "arrow.clockwise") {
            arCoordinator.resetSlice()
        }
    }

    private var hideSliceButton: some View {
        ARCollabViewButton(systemImage: arCoordinator.isSliceHidden ? "eye" : "eye.slash") {
            arCoordinator.toggleHideSlice()
        }
    }
    
    private var toggleSliceOrientationButton: some View {
        ARCollabViewButton(systemImage: "arrow.up.and.down.righttriangle.up.righttriangle.down.fill"){
            arCoordinator.toggleSliceOrientation()
        }
    }

    private var endSessionButton: some View {
        ARCollabViewButton(systemImage: "xmark") {
            arCoordinator.endARSession()
        }
    }

    private var sessionModeControl: some View {
        Picker(selection: $arCoordinator.sessionMode) {
            ForEach(ARCoordinator.SessionMode.allCases, id: \.self) { mode in
                Text(mode.rawValue)
                    .tag(mode)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
    }
}

fileprivate struct ARCollabViewButton: View {
    let systemImage: String
    let action: () -> ()

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.thinMaterial)

                Image(systemName: systemImage)
                    .imageScale(.large)
                    .padding(8)
                    .foregroundStyle(.black)
            }
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    ARCollabView()
        .environmentObject(ARCoordinator())
}
