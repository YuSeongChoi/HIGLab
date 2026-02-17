import AVFoundation

// MARK: - AVAsset

// URL에서 Asset 생성
let url = URL(string: "https://example.com/video.mp4")!
let asset = AVURLAsset(url: url)

// MARK: - 비동기 메타데이터 로드 (권장)

func loadAssetProperties() async {
    do {
        // duration, tracks 등 여러 속성 동시 로드
        let (duration, tracks) = try await asset.load(.duration, .tracks)
        
        print("길이: \(CMTimeGetSeconds(duration))초")
        print("트랙 수: \(tracks.count)")
        
        // 비디오 트랙 정보
        for track in tracks where track.mediaType == .video {
            let (naturalSize, frameRate) = try await track.load(.naturalSize, .nominalFrameRate)
            print("해상도: \(naturalSize.width) x \(naturalSize.height)")
            print("프레임레이트: \(frameRate) fps")
        }
        
        // 오디오 트랙 정보
        for track in tracks where track.mediaType == .audio {
            let descriptions = try await track.load(.formatDescriptions)
            print("오디오 트랙: \(descriptions.count)개")
        }
        
    } catch {
        print("로드 실패: \(error)")
    }
}

// MARK: - 메타데이터 접근

func loadMetadata() async {
    do {
        let metadata = try await asset.load(.metadata)
        
        for item in metadata {
            if let key = item.commonKey?.rawValue,
               let value = try? await item.load(.value) {
                print("\(key): \(value)")
            }
        }
    } catch {
        print("메타데이터 로드 실패: \(error)")
    }
}
