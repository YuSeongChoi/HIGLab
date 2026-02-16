import MultipeerConnectivity
import UIKit

// 기기 이름을 사용한 PeerID 생성
let deviceName = UIDevice.current.name
let peerID = MCPeerID(displayName: deviceName)

// macOS의 경우
#if os(macOS)
import AppKit
let hostName = Host.current().localizedName ?? "Mac"
let macPeerID = MCPeerID(displayName: hostName)
#endif
