import AVFoundation
import Photos
import SwiftUI

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, 
                     didStartRecordingTo fileURL: URL, 
                     from connections: [AVCaptureConnection]) {
        Task { @MainActor in
            isRecording = true
        }
    }
    
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, 
                     didFinishRecordingTo outputFileURL: URL, 
                     from connections: [AVCaptureConnection], 
                     error: Error?) {
        Task { @MainActor in
            isRecording = false
        }
        
        // 에러 확인
        if let error = error {
            print("녹화 중 오류 발생: \(error.localizedDescription)")
            
            // 일부 에러는 파일이 정상 저장된 경우도 있음
            let nsError = error as NSError
            if nsError.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as? Bool != true {
                return
            }
        }
        
        // 사진 라이브러리에 저장
        saveVideoToLibrary(outputFileURL)
    }
    
    private func saveVideoToLibrary(_ url: URL) {
        Task {
            do {
                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                guard status == .authorized || status == .limited else {
                    print("사진 라이브러리 권한이 없습니다.")
                    return
                }
                
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }
                
                print("✅ 비디오가 앨범에 저장되었습니다.")
                
                // 임시 파일 삭제
                try? FileManager.default.removeItem(at: url)
            } catch {
                print("비디오 저장 실패: \(error)")
            }
        }
    }
}
