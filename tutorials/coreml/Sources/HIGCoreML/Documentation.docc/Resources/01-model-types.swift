import CoreML
import Vision

/// CoreML이 지원하는 모델 타입들
enum MLModelType {
    
    // MARK: - 이미지 관련
    
    /// 이미지 분류: 단일 레이블 예측
    /// 예: "강아지", "고양이", "자동차"
    case imageClassification
    
    /// 객체 감지: 여러 객체의 위치와 레이블
    /// 예: 바운딩 박스 + 레이블
    case objectDetection
    
    /// 이미지 세그멘테이션: 픽셀 단위 분류
    /// 예: 배경 vs 인물 분리
    case imageSegmentation
    
    /// 스타일 전이: 이미지 변환
    /// 예: 사진 → 유화 스타일
    case styleTransfer
    
    // MARK: - 텍스트 관련
    
    /// 텍스트 분류: 감정 분석, 스팸 필터
    /// 예: "긍정", "부정", "중립"
    case textClassification
    
    /// 단어 임베딩: 텍스트 → 벡터
    case wordEmbedding
    
    // MARK: - 오디오 관련
    
    /// 사운드 분류: 소리 종류 인식
    /// 예: "개 짖는 소리", "알람", "음악"
    case soundClassification
    
    /// 음성 인식 (Speech Framework와 연동)
    case speechRecognition
    
    // MARK: - 테이블 데이터
    
    /// 회귀: 연속값 예측
    /// 예: 주택 가격 예측
    case regression
    
    /// 테이블 분류: 범주형 예측
    /// 예: 고객 이탈 여부
    case tabularClassification
}
