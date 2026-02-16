// PhotosUI의 장점

import PhotosUI
import SwiftUI

/*
 UIImagePickerController (레거시)
 - 권한 요청 필요 (전체 라이브러리 접근)
 - 단일 선택만 지원
 - UIKit 기반, SwiftUI 래핑 필요
 - 오래된 UI/UX
 
 PhotosPicker (iOS 16+)
 - 권한 요청 불필요! (선택한 사진만 접근)
 - 다중 선택 기본 지원
 - SwiftUI 네이티브
 - 현대적인 UI, 검색, 필터 내장
 */

// PhotosPicker는 out-of-process로 동작합니다.
// 사용자가 선택한 사진만 앱에 전달되므로 프라이버시가 보호됩니다.
