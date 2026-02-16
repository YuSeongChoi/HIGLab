import PDFKit

func unlockPDF(_ document: PDFDocument, password: String) -> Bool {
    // 문서가 암호화되어 있고 잠겨 있는지 확인
    guard document.isEncrypted && document.isLocked else {
        // 이미 잠금 해제되어 있거나 암호화되지 않음
        return true
    }
    
    // 비밀번호로 잠금 해제 시도
    let unlocked = document.unlock(withPassword: password)
    
    if unlocked {
        print("PDF 잠금 해제 성공")
    } else {
        print("잘못된 비밀번호입니다")
    }
    
    return unlocked
}
