//
//  MultipeerSession.swift
//  CollabTest
//
//  Created by Rahul on 3/13/24.
//

import MultipeerConnectivity

protocol ARMultipeerSessionDelegate {
    func didReceiveData(_ data: Data, from id: MCPeerID) -> Void
    func peerDidChangeState(_ peer: MCPeerID, to newState: MCSessionState) -> Void
    func didFindPeer(_ peer: MCPeerID) -> Void
    func didLosePeer(_ peer: MCPeerID) -> Void
}

class MultipeerSession: NSObject, ObservableObject {
    private static let serviceType = "ar-collab"

    private var myPeerID: MCPeerID
    private(set) var session: MCSession!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!

    var arMultipeerSessionDelegate: ARMultipeerSessionDelegate?

    /// - Tag: MultipeerSetup
    init(name: String) {
        myPeerID = MCPeerID(displayName: name)

        super.init()

        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        beginAdvertising()
        beginBrowsing()
    }

    func endSession() {
        session.disconnect()
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }

    func beginAdvertising() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }

    func beginBrowsing() {
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }

    func sendToAllPeers(_ data: Data, reliably: Bool) {
        sendToPeers(data, reliably: reliably, peers: session.connectedPeers)
    }

    /// - Tag: SendToPeers
    func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
        guard !peers.isEmpty else { return }
        do {
            try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
        } catch {
            print("error sending data to peers \(peers): \(error.localizedDescription)")
        }
    }

    func invitePeer(_ peerID: MCPeerID) {
        serviceBrowser.invitePeer(
            peerID,
            to: session,
            withContext: nil,
            timeout: 30
        )
    }
}

extension MultipeerSession: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { self.arMultipeerSessionDelegate?.peerDidChangeState(peerID, to: state) }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { self.arMultipeerSessionDelegate?.didReceiveData(data, from: peerID) }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("This service does not send/receive resources.")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("This service does not send/receive resources.")
    }

}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {

    /// - Tag: FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async { self.arMultipeerSessionDelegate?.didFindPeer(peerID) }
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { self.arMultipeerSessionDelegate?.didLosePeer(peerID) }
    }

}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {

    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Call the handler to accept the peer's invitation to join.
        invitationHandler(true, self.session)
    }
}


