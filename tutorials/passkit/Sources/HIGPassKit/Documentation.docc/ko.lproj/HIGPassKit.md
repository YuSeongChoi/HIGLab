# ``HIGPassKit``

PassKit으로 만드는 멤버십 카드 앱 - Wallet 패스와 Apple Pay 완전 정복

## Overview

이 튜토리얼에서는 PassKit 프레임워크를 사용해 멤버십 카드를 생성하고,
Apple Pay 결제를 통합하는 방법을 단계별로 학습합니다.

### 학습 내용

- **Wallet 패스 생성**: PKPass 구조 이해와 pass.json 디자인
- **패스 서명 & 배포**: 인증서로 서명하고 사용자에게 배포
- **패스 업데이트**: 서버에서 실시간 패스 업데이트 구현
- **Apple Pay 통합**: 결제 요청 구성부터 토큰 처리까지
- **고급 기능**: In-App Provisioning, 결제 시트 커스터마이징

### 요구 사항

- Xcode 15 이상
- iOS 17 이상
- Apple Developer Program 멤버십
- 실제 기기 (시뮬레이터는 Apple Pay 미지원)

## Topics

### Essentials

- <doc:Table-of-Contents>

### Wallet 패스

- <doc:01-Introduction>
- <doc:02-PKPass-Structure>
- <doc:03-Pass-Design>
- <doc:04-Pass-Signing>
- <doc:05-Pass-Update>

### Apple Pay

- <doc:06-Apple-Pay-Basics>
- <doc:07-Payment-Request>
- <doc:08-Payment-Processing>
- <doc:09-In-App-Provisioning>
- <doc:10-Payment-Customization>
