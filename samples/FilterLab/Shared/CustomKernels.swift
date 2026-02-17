// CustomKernels.swift
// FilterLab - 커스텀 Core Image 커널
// HIG Lab 샘플 프로젝트

import CoreImage

// MARK: - 커스텀 커널 프로세서
/// Metal 기반 커스텀 CIKernel을 관리하는 클래스
class CustomKernels {
    
    // MARK: - Metal 커널 소스
    
    /// 커스텀 비네트 커널 (Metal Shading Language)
    /// 가장자리로 갈수록 어두워지는 효과
    private static let vignetteKernelSource = """
    #include <CoreImage/CoreImage.h>
    
    extern "C" {
        float4 customVignette(coreimage::sampler src,
                              float2 center,
                              float radius,
                              float intensity) {
            float2 coord = src.coord();
            float4 color = src.sample(coord);
            
            // 중심으로부터의 거리 계산
            float2 relativeCoord = coord - center;
            float dist = length(relativeCoord) / radius;
            
            // 부드러운 비네트 곡선
            float vignette = 1.0 - smoothstep(0.3, 1.0, dist * intensity);
            
            // RGB에만 비네트 적용 (알파는 유지)
            color.rgb *= vignette;
            
            return color;
        }
    }
    """
    
    /// 컬러 시프트 커널 (RGB 채널 분리 효과)
    private static let colorShiftKernelSource = """
    #include <CoreImage/CoreImage.h>
    
    extern "C" {
        float4 colorShift(coreimage::sampler src,
                          float2 offset,
                          float intensity) {
            float2 coord = src.coord();
            
            // 각 채널별로 다른 오프셋 적용
            float2 redOffset = coord + offset * intensity;
            float2 greenOffset = coord;
            float2 blueOffset = coord - offset * intensity;
            
            // 각 채널 샘플링
            float r = src.sample(redOffset).r;
            float g = src.sample(greenOffset).g;
            float b = src.sample(blueOffset).b;
            float a = src.sample(coord).a;
            
            return float4(r, g, b, a);
        }
    }
    """
    
    /// 픽셀 노이즈 커널
    private static let pixelNoiseKernelSource = """
    #include <CoreImage/CoreImage.h>
    
    extern "C" {
        // 간단한 해시 함수
        float hash(float2 p) {
            float h = dot(p, float2(127.1, 311.7));
            return fract(sin(h) * 43758.5453);
        }
        
        float4 pixelNoise(coreimage::sampler src,
                          float intensity,
                          float seed) {
            float2 coord = src.coord();
            float4 color = src.sample(coord);
            
            // 노이즈 생성
            float noise = hash(coord * 100.0 + seed) * 2.0 - 1.0;
            noise *= intensity;
            
            // 노이즈 적용
            color.rgb += noise;
            color.rgb = clamp(color.rgb, 0.0, 1.0);
            
            return color;
        }
    }
    """
    
    /// 포스터라이즈 커널 (색상 단계화)
    private static let posterizeKernelSource = """
    #include <CoreImage/CoreImage.h>
    
    extern "C" {
        float4 posterize(coreimage::sampler src,
                         float levels) {
            float2 coord = src.coord();
            float4 color = src.sample(coord);
            
            // 색상을 지정된 레벨로 양자화
            float3 posterized = floor(color.rgb * levels) / levels;
            
            return float4(posterized, color.a);
        }
    }
    """
    
    // MARK: - 커널 인스턴스 (지연 초기화)
    
    private lazy var vignetteKernel: CIKernel? = {
        do {
            return try CIKernel(functionName: "customVignette",
                                fromMetalLibraryData: Self.compileMetalSource(Self.vignetteKernelSource))
        } catch {
            print("비네트 커널 컴파일 실패: \(error)")
            return nil
        }
    }()
    
    private lazy var colorShiftKernel: CIKernel? = {
        do {
            return try CIKernel(functionName: "colorShift",
                                fromMetalLibraryData: Self.compileMetalSource(Self.colorShiftKernelSource))
        } catch {
            print("컬러 시프트 커널 컴파일 실패: \(error)")
            return nil
        }
    }()
    
    private lazy var pixelNoiseKernel: CIKernel? = {
        do {
            return try CIKernel(functionName: "pixelNoise",
                                fromMetalLibraryData: Self.compileMetalSource(Self.pixelNoiseKernelSource))
        } catch {
            print("픽셀 노이즈 커널 컴파일 실패: \(error)")
            return nil
        }
    }()
    
    private lazy var posterizeKernel: CIKernel? = {
        do {
            return try CIKernel(functionName: "posterize",
                                fromMetalLibraryData: Self.compileMetalSource(Self.posterizeKernelSource))
        } catch {
            print("포스터라이즈 커널 컴파일 실패: \(error)")
            return nil
        }
    }()
    
    // MARK: - Metal 소스 컴파일
    
    /// Metal 소스를 라이브러리 데이터로 컴파일
    private static func compileMetalSource(_ source: String) -> Data {
        // 실제 앱에서는 미리 컴파일된 .metallib 파일을 사용하는 것이 좋습니다
        // 여기서는 데모를 위해 빈 데이터를 반환하고 폴백 구현을 사용합니다
        return Data()
    }
    
    // MARK: - 필터 적용 메서드
    
    /// 커스텀 비네트 효과 적용
    func applyVignette(to inputImage: CIImage, intensity: Float) -> CIImage {
        // Metal 커널이 사용 불가능한 경우 CIFilter 폴백
        // 실제 앱에서는 미리 컴파일된 Metal 라이브러리를 사용합니다
        
        let extent = inputImage.extent
        let center = CIVector(x: extent.midX, y: extent.midY)
        let radius = min(extent.width, extent.height) / 2
        
        // CIVignetteEffect를 사용한 폴백 구현
        guard let filter = CIFilter(name: "CIVignetteEffect") else {
            return inputImage
        }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(center, forKey: kCIInputCenterKey)
        filter.setValue(intensity * 2, forKey: kCIInputIntensityKey)
        filter.setValue(radius * 0.8, forKey: kCIInputRadiusKey)
        
        return filter.outputImage ?? inputImage
    }
    
    /// 컬러 시프트 효과 적용 (RGB 채널 분리)
    func applyColorShift(to inputImage: CIImage, intensity: Float) -> CIImage {
        // Metal 커널 대신 여러 필터를 조합한 폴백 구현
        
        let extent = inputImage.extent
        
        // 빨간 채널 추출 및 이동
        let redFilter = CIFilter(name: "CIColorMatrix")!
        redFilter.setValue(inputImage, forKey: kCIInputImageKey)
        redFilter.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
        redFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        redFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        redFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        guard let redImage = redFilter.outputImage else { return inputImage }
        
        // 빨간 채널 이동
        let offsetAmount = CGFloat(intensity * 10)
        let redTransform = CGAffineTransform(translationX: offsetAmount, y: 0)
        let shiftedRed = redImage.transformed(by: redTransform)
        
        // 초록 채널 추출 (이동 없음)
        let greenFilter = CIFilter(name: "CIColorMatrix")!
        greenFilter.setValue(inputImage, forKey: kCIInputImageKey)
        greenFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        greenFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        greenFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        greenFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        guard let greenImage = greenFilter.outputImage else { return inputImage }
        
        // 파란 채널 추출 및 반대 방향 이동
        let blueFilter = CIFilter(name: "CIColorMatrix")!
        blueFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blueFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        blueFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        blueFilter.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
        blueFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        guard let blueImage = blueFilter.outputImage else { return inputImage }
        
        let blueTransform = CGAffineTransform(translationX: -offsetAmount, y: 0)
        let shiftedBlue = blueImage.transformed(by: blueTransform)
        
        // 채널 합성 (Screen 블렌딩)
        let addFilter1 = CIFilter(name: "CIAdditionCompositing")!
        addFilter1.setValue(shiftedRed, forKey: kCIInputImageKey)
        addFilter1.setValue(greenImage, forKey: kCIInputBackgroundImageKey)
        
        guard let rgImage = addFilter1.outputImage else { return inputImage }
        
        let addFilter2 = CIFilter(name: "CIAdditionCompositing")!
        addFilter2.setValue(rgImage, forKey: kCIInputImageKey)
        addFilter2.setValue(shiftedBlue, forKey: kCIInputBackgroundImageKey)
        
        guard let result = addFilter2.outputImage else { return inputImage }
        
        // 원본 크기로 크롭
        return result.cropped(to: extent)
    }
    
    /// 픽셀 노이즈 효과 적용
    func applyPixelNoise(to inputImage: CIImage, intensity: Float, seed: Float = 0) -> CIImage {
        // CIRandomGenerator를 사용한 폴백 구현
        guard let noiseFilter = CIFilter(name: "CIRandomGenerator"),
              let noiseImage = noiseFilter.outputImage else {
            return inputImage
        }
        
        // 노이즈를 원본 크기로 크롭
        let croppedNoise = noiseImage.cropped(to: inputImage.extent)
        
        // 노이즈 강도 조절을 위한 색상 조정
        guard let colorFilter = CIFilter(name: "CIColorMatrix") else {
            return inputImage
        }
        
        let scale = CGFloat(intensity * 0.3)
        colorFilter.setValue(croppedNoise, forKey: kCIInputImageKey)
        colorFilter.setValue(CIVector(x: scale, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0, y: scale, z: 0, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: scale, w: 0), forKey: "inputBVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        colorFilter.setValue(CIVector(x: -scale/2, y: -scale/2, z: -scale/2, w: 0), forKey: "inputBiasVector")
        
        guard let adjustedNoise = colorFilter.outputImage else {
            return inputImage
        }
        
        // 원본 이미지와 노이즈 합성
        guard let blendFilter = CIFilter(name: "CIAdditionCompositing") else {
            return inputImage
        }
        
        blendFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blendFilter.setValue(adjustedNoise, forKey: kCIInputBackgroundImageKey)
        
        return blendFilter.outputImage ?? inputImage
    }
    
    /// 포스터라이즈 효과 적용
    func applyPosterize(to inputImage: CIImage, levels: Float) -> CIImage {
        // CIColorPosterize 필터 사용
        guard let filter = CIFilter(name: "CIColorPosterize") else {
            return inputImage
        }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(max(2, levels), forKey: "inputLevels")
        
        return filter.outputImage ?? inputImage
    }
}

// MARK: - CIFilter 확장
extension CIFilter {
    /// 간편한 필터 적용 메서드
    func applied(to image: CIImage) -> CIImage? {
        setValue(image, forKey: kCIInputImageKey)
        return outputImage
    }
}
