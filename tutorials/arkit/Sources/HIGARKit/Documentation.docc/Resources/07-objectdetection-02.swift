import ARKit

// 스캔 완료 후 ARReferenceObject 추출
func extractAndSaveReferenceObject() {
    guard let frame = arView.session.currentFrame else { return }
    
    // 바운딩 박스 정의 (월드 좌표)
    let center = simd_float3(0, 0, -0.5)
    let extent = simd_float3(0.3, 0.3, 0.3)
    
    arView.session.createReferenceObject(
        transform: simd_float4x4(translation: center),
        center: .zero,
        extent: extent
    ) { referenceObject, error in
        
        guard let object = referenceObject else {
            print("객체 생성 실패: \(error?.localizedDescription ?? "")")
            return
        }
        
        // 파일로 저장
        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let fileURL = documentsURL.appendingPathComponent("scanned_object.arobject")
        
        do {
            try object.export(to: fileURL)
            print("객체 저장 완료: \(fileURL)")
        } catch {
            print("저장 실패: \(error)")
        }
    }
}
