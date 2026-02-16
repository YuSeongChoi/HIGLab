import MultipeerConnectivity

// sendResource: 파일(리소스) 전송
// - resourceAt: 전송할 파일의 URL
// - withName: 수신자에게 표시될 파일 이름
// - toPeer: 대상 피어
// - withCompletionHandler: 완료 콜백
// - 반환값: 진행률 추적을 위한 Progress

let session: MCSession = // ...
let fileURL = URL(fileURLWithPath: "/path/to/file.pdf")
let peer: MCPeerID = // ...

let progress = session.sendResource(
    at: fileURL,
    withName: "document.pdf",
    toPeer: peer
) { error in
    if let error = error {
        print("전송 실패: \(error)")
    } else {
        print("전송 완료")
    }
}
