//
//  PeerConnectionTransport.swift
//  
//
//  Created by Russell D'Sa on 2/14/21.
//

import Foundation
import WebRTC
import Promises

class PeerConnectionTransport {
    var peerConnection: RTCPeerConnection
    var pendingCandidates: [RTCIceCandidate] = []
    
    init(config: RTCConfiguration, delegate: RTCPeerConnectionDelegate) {
        peerConnection = RTCEngine.factory.peerConnection(with: config,
                                                          constraints: RTCEngine.connConstraints,
                                                          delegate: delegate)
    }
    
    func addIceCandidate(candidate: RTCIceCandidate) {
        if peerConnection.remoteDescription != nil {
            peerConnection.add(candidate)
        } else {
            pendingCandidates.append(candidate)
        }
    }
    
    func setRemoteDescription(_ sdp: RTCSessionDescription, completionHandler: ((Error?) -> Void)? = nil) {
        peerConnection.setRemoteDescription(sdp) { error in
            if error != nil {
                completionHandler?(error)
                return
            }
            
            for pendingCandidate in self.pendingCandidates {
                self.peerConnection.add(pendingCandidate)
            }
            self.pendingCandidates.removeAll()
            completionHandler?(nil)
        }
    }
    
    func close() {
        peerConnection.close()
    }
}

